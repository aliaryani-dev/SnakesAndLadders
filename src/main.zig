const std = @import("std");
var stdout_buffer:[1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
const c = @cImport({
    @cInclude("time.h");
    @cInclude("stdlib.h");
    @cInclude("stdio.h");
});

fn roll_dice() c_int {
    const roll:c_int = @intCast(@rem(c.rand(), 6) + 1);
    return roll;
}

var player1:c_int = 0;
var player2:c_int = 0;

fn print_board() !void {
    var board:[101]u64 = undefined;
    for (1..101) |i| {
        board[i] = i;
    }

    var alt:c_int = 0; // to specify alternates
    var iterLR:c_int = 101; // iterator to print from left to right
    var iterRL:c_int = 80; // iterator to print from right to left 
    var val:c_int = 100;

    while (val!=0) : (val-= 1) {
        if (alt == 0) {
            iterLR -= 1;
            if (iterLR == player1) {
                try stdout.print("#P1    ", .{});
            } else if (iterLR == player2) {
                try stdout.print("#P2    ", .{});
            } else {
                try stdout.print("{d}    ", .{board[@intCast(iterLR)]});
            } try stdout.flush();

            if (@mod(iterLR, 10) == 1) {
                try stdout.print("\n\n", .{});
                try stdout.flush();
                alt = 1;
                iterLR -= 10;
            } 
        } else {
            iterRL += 1;
            if (iterRL == player1) {
                try stdout.print("#P1    ", .{});
            } else if (iterRL == player2) {
                try stdout.print("#P2    ", .{});
            } else {
                try stdout.print("{d}    ", .{board[@intCast(iterRL)]});
            } try stdout.flush();

            if (@mod(iterRL, 10) == 0) {
                try stdout.print("\n\n", .{});
                try stdout.flush();
                alt = 0;
                if(iterRL - 30 >= 0) iterRL -= 30;
            }
        }
        if (iterRL == 10)
            break;
    }
    try stdout.print("\n", .{});
    try stdout.flush();
}

// function to move player 
fn move_player(current_player:c_int,roll:c_int) c_int {
    const new_position:usize = @intCast(current_player + roll);
    if (new_position > 100)
        return current_player;

    var snakes_and_ladders:[101]c_int = undefined;
    for (0..101) |i| {
        snakes_and_ladders[i] = 0;
    }

    // positive values are ladders 
    // negative values are snakes 
    snakes_and_ladders[6] = 40;
    snakes_and_ladders[23] = -10;
    snakes_and_ladders[45] = -7;
    snakes_and_ladders[61] = -18;
    snakes_and_ladders[65] = -8;
    snakes_and_ladders[98] = -10;
    
    const new_square:c_int = @intCast(@as(c_int,@intCast(new_position)) + snakes_and_ladders[@intCast(new_position)]);
    if (new_square > 100)
        return current_player;
    
    return new_square;
}

pub fn main() !void {
    c.srand(@intCast(c.time(0)));
    var current_player:c_int = 1;
    var won:bool = false;
    
    try stdout.print("Snake And Ladder game\n", .{});
    while (!won) {
        try stdout.print("\nPlayer {d}, press Enter to roll the dice...", .{current_player});
        try stdout.flush();
        _ = c.getchar();
        const roll = roll_dice();
        try stdout.print("You rolled: {d}\n", .{roll});
        try stdout.flush();

        if (current_player == 1) {
            player1 = move_player(player1, roll);
            try stdout.print("Player 1 is now at square {d}\n\n", .{player1});
            try print_board();
            if (player1 == 100) {
                try stdout.print("Player 1 wins!\n", .{});
                try stdout.flush();
                won = true;
            }
        } else {
            player2 = move_player(player2, roll);
            try stdout.print("Player 2 is now at square {d}\n\n", .{player2});
            try print_board();
            if (player2 == 100) {
                try stdout.print("Player 2 wins!\n", .{});
                try stdout.flush();
                won = true;
            }
        }
        // switch to other player 
        current_player = if (current_player == 1) 2 else 1;
    }
}
