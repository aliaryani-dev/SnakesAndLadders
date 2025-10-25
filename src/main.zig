const std = @import("std");
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

    var alt = 0;
    var iterLR = 101; // iterator to print from left to right
    var iterRL = 80; // iterator to print from right to left 
    var val = 100;
}
