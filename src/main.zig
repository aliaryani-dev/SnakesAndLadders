const std = @import("std");
var stdout_buffer:[1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
const c = @cImport({
    @cInclude("stdlib.h");
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
    }
}
