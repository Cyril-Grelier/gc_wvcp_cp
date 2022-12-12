/*
 *
 * main.cpp
 *
 *  Created on: 14/09/2015
 *      Author: bruno
 */

#include "ArgPack.h"
#include "Graph.h"
#include "InitError.h"
#include "bossa_timer.h"

#include <fstream>
#include <ilcplex/ilocplex.h>
#include <iostream>
#include <random>
#include <string>

using namespace std;
using namespace opt;

namespace opt {

// Mersenne Twister 19937 generator

mt19937 generator;

Graph *auxGraphConversion(const Graph *graph) {
    vector<int> order(graph->n());
    vector<int> position(graph->n());

    for (int i = 0; i < graph->n(); i++) {
        order[i] = i;
    }

    std::sort(order.begin(), order.end(), [graph](const int &a, const int &b) {
        return (graph->weight(a) > graph->weight(b));
    });

    for (int i = 0; i < graph->n(); i++) {
        position[order[i]] = i;
    }

    Graph *aux = new Graph(graph->m());
    aux->VertexMap = vector<int>(graph->m(), -1);
    vector<vector<int>> incidenceMatrix(graph->n(), vector<int>(graph->n(), 0));
    vector<vector<int>> mapMatrix(graph->n(), vector<int>(graph->n(), -1));

    int map = 0;
    for (int v = 0; v < graph->n(); v++) {
        for (int neighbor : graph->adj_l(v)) {
            if (position[v] > position[neighbor]) {
                incidenceMatrix[v][neighbor] = -1;
            } else {
                incidenceMatrix[v][neighbor] = 1;
                mapMatrix[v][neighbor] = map;
                aux->weight(map, graph->weight(neighbor));
                aux->VertexMap[map] = v;
                map++;
            }
        }
    }

    assert(map == graph->m());

    for (int i = 0; i < graph->n(); i++) {
        vector<int> input;
        vector<int> output;
        for (int j = 0; j < graph->n(); j++) {
            if (incidenceMatrix[i][j] == 1) {
                output.push_back(j);
            } else if (incidenceMatrix[i][j] == -1) {
                input.push_back(j);
            }
        }

        for (int e1 = 0; e1 < (int)output.size() - 1; e1++) {
            for (int e2 = e1 + 1; e2 < (int)output.size(); e2++) {
                int w = output[e1];
                int v = output[e2];
                if (incidenceMatrix[v][w] == 0) {
                    assert(graph->weight(i) >= graph->weight(w));
                    assert(graph->weight(i) >= graph->weight(v));
                    int map1 = mapMatrix[i][w];
                    int map2 = mapMatrix[i][v];
                    assert(map1 != -1 && map2 != -1);
                    assert(graph->weight(w) == aux->weight(map1));
                    assert(graph->weight(v) == aux->weight(map2));
                    aux->addEdge(map1, map2);
                }
            }
        }

        for (int e1 = 0; e1 < (int)input.size() - 1; e1++) {
            for (int e2 = e1 + 1; e2 < (int)input.size(); e2++) {
                int w = input[e1];
                int v = input[e2];
                assert(graph->weight(w) >= graph->weight(i));
                assert(graph->weight(v) >= graph->weight(i));
                int map1 = mapMatrix[w][i];
                int map2 = mapMatrix[v][i];
                assert(map1 != -1 && map2 != -1);
                assert(graph->weight(i) == aux->weight(map1));
                assert(graph->weight(i) == aux->weight(map2));
                aux->addEdge(map1, map2);
            }
        }

        for (int e1 = 0; e1 < (int)input.size(); e1++) {
            for (int e2 = 0; e2 < (int)output.size(); e2++) {
                int w = input[e1];
                int v = output[e2];
                assert(graph->weight(w) >= graph->weight(i));
                assert(graph->weight(i) >= graph->weight(v));
                int map1 = mapMatrix[i][v];
                int map2 = mapMatrix[w][i];
                assert(map1 != -1 && map2 != -1);
                assert(graph->weight(v) == aux->weight(map1));
                assert(graph->weight(i) == aux->weight(map2));
                aux->addEdge(map1, map2);
            }
        }
    }

    return aux;
}

Graph *readInstance(const string &filename1, const string &filename2) {
    int m = 0;       // number of vertices and edges announced
    int m_count = 0; // number of edges actually counted
    int v1, v2, v3;
    char buffer[500];
    int linenum = 0;
    ifstream input1(filename1.c_str());
    ifstream input2(filename2.c_str());
    Graph *graph = NULL;

    if (!input1) {
        throw InitError("error opening the input file: " + filename1 + "\n");
    } else if (!filename2.empty() && !input2) {
        throw InitError("error opening the input file: " + filename2 + "\n");
    }

    do {
        input1.getline(buffer, 500);
        linenum++;
    } while (buffer[0] == 'c');

    // DIMACS format
    if (sscanf(buffer, "p %*s %d %d", &v1, &v2) == 2) {
        if (v1 < 0 || v2 < 0) {
            input1.close();
            throw InitError("syntax error in line " + std::to_string(linenum) + " of " +
                            filename1 +
                            ". The number of edges and vertices must not be negative.\n");
        }

        graph = new Graph(v1);
        for (int idx1 = 0; idx1 < v1; idx1++) {
            for (int idx2 = idx1 + 1; idx2 < v1; idx2++) {
                graph->addEdge(idx1, idx2);
                m_count++;
            }
        }

        while (input1.getline(buffer, 500)) {
            linenum++;

            if (sscanf(buffer, "e %d %d", &v1, &v2) == 2) {
                graph->removeEdge(v1 - 1, v2 - 1);
                m_count--;
            } else if (sscanf(buffer, "e %d %d %d", &v1, &v2, &v3) == 3) {
                graph->removeEdge(v1 - 1, v2 - 1);
                m_count--;
            } else if (sscanf(buffer, "n %d %d", &v1, &v2) == 2) {
                graph->weight(v1 - 1, v2);
            } else if (buffer[0] == 'c') {
                continue;
            } else if (sscanf(buffer, "%d %d", &v1, &v2) == 2) {

            } else {
                input1.close();
                throw InitError("syntax error in line " + std::to_string(linenum) +
                                " of " + filename1 + "\n");
            }

            if (v1 < 0 || v2 < 0) {
                input1.close();
                throw InitError("syntax error in line " + std::to_string(linenum) +
                                " of " + filename1 +
                                ". Vertices label must not be negative.\n");
            }
        }
        input1.close();

        // if (m_count != m) {
        // 	throw InitError("the number of edges announced is not equal to the number of
        // edges read.\n");
        // }

        linenum = 0;

        while (!filename2.empty() && input2.getline(buffer, 256)) {
            if (sscanf(buffer, "%d", &v1) == 1) {
                graph->weight(linenum, v1);
            } else {
                input1.close();
                throw InitError("syntax error in line " + std::to_string(linenum + 1) +
                                " of " + filename2 + "\n.");
            }

            if (v1 < 0) {
                input1.close();
                throw InitError("syntax error in line " + std::to_string(linenum + 1) +
                                " of " + filename2 +
                                ". Vertices weight must not be negative.\n");
            }
            linenum++;
        }
        input2.close();

        // matrix format
    } else if (sscanf(buffer, "%d %d", &v1, &v2) == 2 && v1 == v2) {
        if (v1 < 0 || v2 < 0) {
            input1.close();
            throw InitError("syntax error in line " + std::to_string(linenum) + " of " +
                            filename1 + ". Matrix dimensions should not be negative.\n");
        }

        int matrix[v1][v2];
        // read matrix and define of number of vertices
        int vertices = 0;
        for (int i = 0; i < v1; i++) {
            for (int j = 0; j < v2; j++) {
                input1 >> v3;
                matrix[i][j] = v3;
                if (v3 != 0) {
                    vertices++;
                }
            }
        }

        graph = new Graph(vertices);
        for (int idx1 = 0; idx1 < vertices; idx1++) {
            for (int idx2 = idx1 + 1; idx2 < vertices; idx2++) {
                graph->addEdge(idx1, idx2);
            }
        }

        // define weight of each vertex and a mapping
        // between the matrix and the graph vertices
        int map[v1][v2];
        int v = 0;
        for (int i = 0; i < v1; i++) {
            for (int j = 0; j < v2; j++) {
                if (matrix[i][j] != 0) {
                    map[i][j] = v;
                    graph->weight(v, matrix[i][j]);
                    v++;
                }
            }
        }

        // assign edges for each line i
        for (int i = 0; i < v1; i++) {
            for (int j1 = 0; j1 < v2 - 1; j1++) {
                for (int j2 = j1 + 1; j2 < v2; j2++) {
                    if (matrix[i][j1] != 0 && matrix[i][j2] != 0) {
                        graph->removeEdge(map[i][j1], map[i][j2]);
                    }
                }
            }
        }

        // assign edges for column line j
        for (int j = 0; j < v2; j++) {
            for (int i1 = 0; i1 < v1 - 1; i1++) {
                for (int i2 = i1 + 1; i2 < v1; i2++) {
                    if (matrix[i1][j] != 0 && matrix[i2][j] != 0) {
                        graph->removeEdge(map[i1][j], map[i2][j]);
                    }
                }
            }
        }
    } else {
        input1.close();
        throw InitError("syntax error in line " + std::to_string(linenum) + " of " +
                        filename1 + "\n");
    }
    return graph;
} // Graph *readInstance (const string &filename)

} // namespace opt

/****************
 *
 * Main function
 *
 ****************/

int main(int argc, char *argv[]) {
    try {

        BossaTimer input_timer, proc_timer;
        double target_time = -1;
        int target_iterations = -1;
        input_timer.start();

        // read input parameters

        ArgPack single_ap(argc, argv);

        // set the random seed

        generator.seed(ArgPack::ap().rand_seed);

        // read instance

        Graph *graph_complement =
            readInstance(ArgPack::ap().input_name1, ArgPack::ap().input_name2);
        Graph *graph_instance = auxGraphConversion(graph_complement);
        input_timer.pause();

        proc_timer.start();

        IloEnv env;
        IloModel model(env, "Minimum sum coloring problem");
        IloIntVarArray x(env, graph_instance->n(), 0, 1);
        IloExpr FO(env);

        char name[20];
        for (int i = 0; i < graph_instance->n(); i++) {
            sprintf(name, "x[%d]", i);
            x[i].setName(name);
            model.add(x[i]);
        }

        IloCplex cplex(model);

        for (unsigned v = 0; v < graph_instance->n(); v++) {
            FO += graph_instance->weight(v) * x[v];
            for (int neighbor : graph_instance->adj_l(v)) {
                if (v < neighbor) {
                    model.add(x[v] + x[neighbor] <= 1);
                }
            }
        }
        FO = FO;
        model.add(IloMaximize(env, FO));
        cplex.setParam(IloCplex::TiLim, ArgPack::ap().time);
        cplex.setParam(IloCplex::Threads, 1);
        cout << "Total weight = " << graph_complement->total_weight() << "\n";
        cplex.solve();

        cout << "Result = " << graph_complement->total_weight() - cplex.getObjValue()
             << endl;

        delete (graph_instance);
        delete (graph_complement);

    } catch (std::exception &e) { cerr << e.what(); }

    return 0;
} // int main(int argc, char *argv[])