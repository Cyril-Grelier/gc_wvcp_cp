# import os


# def main():
#     """for each instance of the problem, compute the cliques"""
#     problem = "wvcp"
#     instances_names: list[str] = []
#     # with open(
#     #     f"instances/instance_list_{problem}.txt", "r", encoding="utf8"
#     # ) as instances_file:
#     #     instances_names = instances_file.read().splitlines()
#     with open("instance_feasible.txt", "r", encoding="utf8") as instances_file:
#         instances_names = instances_file.read().splitlines()
#     for instance_name in instances_names:
#         repertory_red: str = f"reduced_{problem}_dzn"
#         if not os.path.exists(f"{repertory_red}/{instance_name}.dzn"):
#             print(f"{repertory_red}/{instance_name}.dzn")
#         repertory_or: str = f"original_{problem}_dzn/"
#         if not os.path.exists(f"{repertory_or}/{instance_name}.dzn"):
#             print(f"{repertory_or}/{instance_name}.dzn")


# if __name__ == "__main__":
#     main()
import os


def main():
    """for each instance of the problem, compute the cliques"""
    problem = "wvcp"
    with open(
        f"instances/instance_list_{problem}.txt", "r", encoding="utf8"
    ) as instances_file:
        instances_names_all = instances_file.read().splitlines()
    with open("instance_feasible.txt", "r", encoding="utf8") as instances_file:
        instances_names = instances_file.read().splitlines()
    print(sorted(list(set(instances_names_all).difference(instances_names))))


if __name__ == "__main__":
    main()
# instances retirés :
# ['C2000.5', 'C2000.9', 'flat1000_50_0', 'flat1000_60_0', 'flat1000_76_0', 'latin_square_10', 'wap01a', 'wap02a', 'wap03a', 'wap04a', 'wap07a', 'wap08a']
