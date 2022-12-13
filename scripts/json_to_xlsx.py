"""
Generate a xlsx file containing results of given methods from json files.

Follow the main function to manage the files and parameters
"""
import re
import statistics
from glob import glob
from typing import Any, Iterable
import json
import os

import pandas as pd  # type: ignore
from openpyxl import Workbook  # type: ignore
from openpyxl.styles import Alignment, Font  # type: ignore
from openpyxl.utils import get_column_letter  # type: ignore


# When a best score is equal to the best known score : red
COLOR_BEST = "ff0000"
# When a best score is proven optimal : blue
COLOR_OPTIMAL = "0000ff"
# When a best score is a new proven optimal : blue
COLOR_NEW_OPTIMAL = "00ff00"
# When a best score is better than the best known score : green
COLOR_NEW_BEST = "FF7F00"


def main():
    """
    Choose the methods and instances and create the xlsx file
    """
    # Add method name and repertory of data of each method
    methods: list[tuple(str, str)] = [
        # E1
        ("primal static", "cp_1h_E1_feasible/E1_primal_static"),
        ("primal dyn", "cp_1h_E1_feasible/E1_primal_dynamic"),
        ("dual ortools", "cp_1h_E1_feasible/E1_dual_ortool"),
        ("dual coin-bc", "cp_1h_E1_feasible/E1_dual_coin_bc"),
        ("dual cplex", "cp_1h_E1_feasible/E1_dual_cplex"),
        ("joint static", "cp_1h_E1_feasible/E1_joint_static"),
        ("joint dyn", "cp_1h_E1_feasible/E1_joint"),
    ]

    problem = "wvcp"

    # Choose the set of instances
    instances_set = ("pxx", "pxx")
    instances_set = ("rxx", "rxx")
    instances_set = ("DIMACS_non_optimal", "dimacs_no")
    instances_set = ("DIMACS_optimal", "dimacs_o")
    instances_set = ("../instances_coeff", "instances_coeff")
    instances_set = ("../instances_hard_wvcp", "hard_wvcp")
    instances_set = ("../instances_non_optimal", "non_optimal")
    instances_set = ("instance_list_wvcp", "all")
    instances_set = ("../instance_feasible", "feasible")

    instance_type = "reduced"
    instance_type = "original"

    output_file = f"xlsx_files/E1_1h_{instance_type}_{instances_set[1]}.xlsx"

    with open(f"instances/{instances_set[0]}.txt", "r", encoding="utf8") as file:
        instances = [i[:-1] for i in file.readlines()]

    table = Table(
        methods=methods,
        instances=instances,
        problem=problem,
        instance_type=instance_type,
    )
    table.to_xlsx(output_file)
    print(output_file)


class Method:
    def __init__(
        self, name: str, repertory: str, instance_name, instance_type: str
    ) -> None:
        self.name: str = name
        self.repertory: str = repertory
        self.flat_time: float = float("inf")
        self.solve_time: float = float("inf")
        self.score: float = float("inf")
        self.optimality_time: float = float("inf")
        self.optimal: bool = False
        self.objective_bound: float = float("inf")
        self.failures: float = float("inf")

        # load data
        json_file = f"outputs/{repertory}/{instance_type}_{instance_name}.json"
        cplex_file = f"outputs/{repertory}/{instance_type}_{instance_name}.cplex"
        if os.path.exists(json_file):
            with open(json_file, "r", encoding="utf8") as file:
                for line in file.readlines():
                    l_json = json.loads(line)
                    if l_json["type"] == "statistics":
                        if "flatTime" in l_json["statistics"]:
                            self.flat_time = round(l_json["statistics"]["flatTime"], 1)
                            if self.flat_time > 3600:
                                print(instance_name, "flat time > 3600")
                        else:
                            if self.optimal:
                                self.optimality_time = round(
                                    l_json["statistics"]["solveTime"], 1
                                )
                            else:
                                self.solve_time = round(
                                    l_json["statistics"]["solveTime"], 1
                                )
                            try:
                                self.objective_bound = l_json["statistics"][
                                    "objectiveBound"
                                ]
                            except:
                                pass
                            try:
                                self.failures = l_json["statistics"]["failures"]
                            except:
                                self.objective_bound = round(self.objective_bound, 2)
                    elif l_json["type"] == "solution":
                        if "x_score" in l_json["output"]["json"]:
                            self.score = l_json["output"]["json"]["x_score"]
                        else:
                            self.score = l_json["output"]["json"]["yx_score"]
                    elif l_json["type"] == "status":
                        self.optimal = l_json["status"] == "OPTIMAL_SOLUTION"
        elif os.path.exists(cplex_file):
            self.flat_time = 0
            with open(cplex_file, "r", encoding="utf8") as file:
                for line in file.readlines():
                    split = line.split()
                    if line.startswith("Result"):
                        self.score = int(split[-1])
                    if line.startswith("Total (root+branch&cut)"):
                        self.solve_time = float(split[3])
                    if split and split[-1] == "0.00%":
                        self.optimal = True
                    if line.startswith("All rows and columns eliminated."):
                        self.optimal = True


class Instance:
    """Store the results of all given method on one instance"""

    def __init__(
        self,
        name: str,
        methods: list[tuple[str, str]],
        problem: str,
        instance_type: str,
    ) -> None:
        self.name: str = name
        self.nb_vertices: int
        self.nb_edges: int
        self.best_known_score: int
        self.optimal: bool

        self.methods: dict[str, Method] = {
            m_name: Method(m_name, repertory, name, instance_type)
            for m_name, repertory in methods
        }
        self.methods_names: list[str] = [m_name for m_name, _ in methods]

        # get informations on the instance
        self.nb_vertices, self.nb_edges, self.density = get_density(name, instance_type)
        self.best_known_score, self.optimal = get_best_known_score(name, problem)


class Table:
    """Representation of the data table"""

    def __init__(
        self,
        methods: list[tuple[str, str]],
        instances: list[str],
        problem: str,
        instance_type: str,
    ) -> None:

        self.methods_names: list[str] = [m_name for m_name, _ in methods]

        self.instances: list[Instance] = [
            Instance(instance, methods, problem, instance_type)
            for instance in instances
        ]

        self.nb_optim = {
            m: sum(1 for instance in self.instances if instance.methods[m].optimal)
            for m in self.methods_names
        }

    def __repr__(self) -> str:
        return "\n".join([str(instance) for instance in self.instances])

    def table_results(self, workbook: Workbook):
        sheet = workbook.active
        sheet.title = "results"
        # first row
        # first columns are the instances informations then the methods names
        instance_info = ["instance", "|V|", "|E|", "density", "BKS", "optim"]
        columns_info = [
            "score",
            "flat(s)",
            "solve(s)",
            "opti(s)",
            "LB",
            "failures",
        ]
        line: list[int | str | float] = list(instance_info)
        line += [m for m in self.methods_names for _ in columns_info]
        sheet.append(line)
        # merge first row for methods names
        for i in range(len(self.methods_names)):
            sheet.merge_cells(
                start_row=1,
                end_row=1,
                start_column=len(instance_info) + 1 + len(columns_info) * i,
                end_column=len(instance_info) + len(columns_info) * (i + 1),
            )

        # second row
        # instance informations then columns info
        line = list(instance_info)
        for _ in self.methods_names:
            line += list(columns_info)
        sheet.append(line)

        # merge 2 firsts lines for instances informations
        for i in range(len(instance_info)):
            sheet.merge_cells(
                start_row=1, end_row=2, start_column=i + 1, end_column=i + 1
            )

        # body of the table
        # first columns are the instance info then the scores, times,... for each methods
        for instance in self.instances:
            line = [
                instance.name,
                instance.nb_vertices,
                instance.nb_edges,
                instance.density,
                instance.best_known_score,
                instance.optimal,
            ]
            for m in self.methods_names:
                method = instance.methods[m]
                line += [
                    method.score,
                    method.flat_time,
                    method.solve_time,
                    method.optimality_time,
                    method.objective_bound,
                    method.failures,
                ]
            sheet.append(line)
            for col, m in enumerate(self.methods_names):
                column_best_score = len(instance_info) + 1 + len(columns_info) * col
                cell_best_score = sheet.cell(sheet.max_row, column_best_score)
                if cell_best_score.value == float("inf"):
                    continue
                val_best_score = int(cell_best_score.value)
                if val_best_score == instance.best_known_score:
                    cell_best_score.font = Font(bold=True, color=COLOR_BEST)
                elif val_best_score < instance.best_known_score:
                    cell_best_score.font = Font(bold=True, color=COLOR_NEW_BEST)
                if instance.methods[m].optimal and instance.optimal:
                    cell_best_score.font = Font(bold=True, color=COLOR_OPTIMAL)
                elif instance.methods[m].optimal:
                    cell_best_score.font = Font(bold=True, color=COLOR_NEW_OPTIMAL)

        # footer

        # nb optimal
        line = ["nb prove optimal"] * len(instance_info)
        for m in self.methods_names:
            line += [f"{self.nb_optim[m]}/{len(self.instances)}"] * len(columns_info)
        sheet.append(line)
        # merge footer
        sheet.merge_cells(
            start_row=sheet.max_row,
            end_row=sheet.max_row,
            start_column=1,
            end_column=len(instance_info),
        )
        for i, _ in enumerate(self.methods_names):
            sheet.merge_cells(
                start_row=sheet.max_row,
                end_row=sheet.max_row,
                start_column=len(instance_info) + 1 + len(columns_info) * i,
                end_column=len(instance_info) + len(columns_info) * (i + 1),
            )

        # Set alignment
        for col_ in sheet.columns:
            for cell in col_:
                cell.alignment = Alignment(horizontal="center", vertical="center")

        # Set optimal width
        column_widths: list[int] = []
        for row in sheet:
            for i, cell in enumerate(row):
                if len(column_widths) > i:
                    if len(str(cell.value)) + 1 > column_widths[i]:
                        column_widths[i] = len(str(cell.value)) + 1
                else:
                    column_widths += [0]
        for i, column_width in enumerate(column_widths, start=1):
            sheet.column_dimensions[get_column_letter(i)].width = column_width

        # Freeze row and columns
        sheet.freeze_panes = sheet["G3"]

    def to_xlsx(self, file_name: str):
        """Convert the table to xlsx file"""
        workbook = Workbook()

        # first sheet with all results of each methods
        self.table_results(workbook)

        workbook.save(file_name)


def get_best_known_score(instance: str, problem: str) -> tuple[int, bool]:
    """return best know score in the literature and if score optimal"""
    file: str = f"instances/best_scores_{problem}.txt"
    with open(file, "r", encoding="utf8") as f:
        for line in f.readlines():
            instance_, score, optimal = line[:-1].split(" ")
            if instance_ == instance:
                return int(score), optimal == "*"
    raise Exception(f"instance {instance} not found in {file}")


def get_density(instance: str, instance_type: str) -> tuple[int, int, float]:
    """return nb vertices, nb edges and density"""
    info_file = f"density_{instance_type}.csv"
    with open(info_file, "r", encoding="utf8") as file:
        for line in file.readlines():
            instance_, nb_vertices, nb_edges, density = line[:-1].split(",")
            if instance_ != instance:
                continue
            return int(nb_vertices), int(nb_edges), round(float(density), 2)
    print(f"instance {instance} not found in {info_file}")
    return -1, -1, -1


if __name__ == "__main__":
    main()
