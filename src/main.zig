const std = @import("std");
var stdout_buffer:[1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
const c = @cImport({
    @cInclude("time.h");
    @cInclude("stdlib.h");
    @cInclude("stdio.h");
});

fn roll_dice() u8 {
    return c.rand() % 6 + 1;
}

var player1:u8 = 0;
var player2:u8 = 0;

fn print_board() !void {
    var board = [101]u8{};
    for (1..101) |i| {
        board[i] = i;
    }

    var alt = 0; // to specify alternates
    var iterLR = 101; // iterator to print from left to right
    var iterRL = 80; // iterator to print from right to left 
    var val = 100;

    while (val) : (val-= 1) {
        if (alt == 0) {
            iterLR -= 1;
            if (iterLR == player1) {
                try stdout.print("#P1    ", .{});
            } else if (iterLR == player2) {
                try stdout.print("#P2    ", .{});
            } else {
                try stdout.print("{d}    ", .{board[iterLR]});
            } try stdout.flush();

            if (iterLR % 10 == 1) {
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
                try stdout.print("{d}    ", .{board[iterRL]});
            } try stdout.flush();

            if (iterRL % 10 == 0) {
                try stdout.print("\n\n", .{});
                try stdout.flush();
                alt = 0;
                iterRL -= 30;
            }
        }
        if (iterRL == 10)
            break;
    }
    try stdout.print("\n", .{});
    try stdout.flush();
}

// function to move player 
fn move_player(current_player:u8,roll:u8) u8 {
    const new_position = current_player + roll;

    var snakes_and_ladders = [101]i16{};
    for (0..101) |i| {
        snakes_and_ladders[i] = 0;
    }

    // positive values are ladders 
    // negative values are snakes 
    snakes_and_ladders[6] = 40;
    snakes_and_ladders[24] = -10;
    snakes_and_ladders[45] = -30;
    snakes_and_ladders[61] = -18;
    snakes_and_ladders[58] = 22;
    snakes_and_ladders[66] = 9;
    snakes_and_ladders[98] = -20;

    const new_square = new_position + snakes_and_ladders[new_position];
    if (new_square > 100)
        return current_player;
    
    return new_square;
}

pub fn main() !void {
    c.srand(c.time(0));
    var current_player = 1;
    var won = false;
    
    try stdout.print("Snake And Ladder game\n", .{});
    while (!won) {
        try stdout.print("\nPlayer {d}, press Enter to roll the dice...", .{current_player});
        try stdout.flush();
        c.getchar();
        const roll = roll_dice();
        try stdout.print("You rolled: {d}\n", .{roll});
        try stdout.flush();

        
    }
}
