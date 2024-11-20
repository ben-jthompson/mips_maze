# wall = 1 and path = 0
maze = [[1, 1, 0, 0],
        [1, 1, 0, 1],
        [0, 0, 0, 1],
        [0, 1, 0, 0]
        ]

robot_row = 3
robot_col = 0
step_counter = 0
mistake_counter = 0
rows = len(maze)
cols = len(maze[0])
exit_row = 0
exit_col = 3


def print_maze(maze, robot_row, robot_col):
    for i in range(len(maze)):
        row = ""
        for j in range(len(maze[i])):
            if i == robot_row and j == robot_col:  # robot position
                row += "> "
            elif maze[i][j] == 1:  # wall
                row += "X "
            else:
                row += ". "  # path
        print(row)


def robot_move(robot_row, robot_col, direction):
    if direction == "f":
        return robot_row, robot_col + 1  # move forward (right)
    elif direction == "b":
        return robot_row, robot_col - 1  # move backward (left)
    elif direction == "l":
        return robot_row - 1, robot_col  # move left (up)
    elif direction == "r":
        return robot_row + 1, robot_col  # move right (down)
    else:
        return robot_row, robot_col  # no move if input invalid


def is_valid_move(x, y, maze):
    # check bounds and wall condition
    if 0 <= x < rows and 0 <= y < cols and maze[x][y] == 0:
        return True
    else:
        return False

complementary_directions = {"f":"b", "b":"f", "l":"r", "r":"l"}
in_wall = False
print_maze(maze, robot_row, robot_col)
while (robot_row, robot_col) != (exit_row, exit_col):
    direction = input("Enter your move (F/B/L/R): ").strip().lower()
    if in_wall:
        valid_directions = complementary_directions[prev]
    else:
        valid_directions = ["f", "b", "l", "r"]

    if direction in valid_directions:
        # calculate the new position
        new_row, new_col = robot_move(robot_row, robot_col, direction)

        # check boundaries
        if not (0 <= new_row < rows and 0 <= new_col < cols):
            print("Out of bounds! Stay inside the maze.\n")
            mistake_counter += 1
            continue

        # always update the robot's position, even if invalid
        robot_row, robot_col = new_row, new_col
        print_maze(maze, robot_row, robot_col)
        if is_valid_move(new_row, new_col, maze):
            print("Valid move!")
            in_wall = False
            step_counter += 1
        else:  # invalid move
            mistake_counter += 1
            in_wall = True
            prev = direction
            print("Invalid move! You hit a wall. Move out of it!\n")
    else:
        print(f"Invalid direction! Please use {complementary_directions[prev]} to move out of the wall.\n")

print("You reached the exit!")
print(f"Total steps: {step_counter}")
print(f"Mistakes: {mistake_counter}")