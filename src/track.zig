const std = @import("std");
pub const Clip = @import("clip.zig").Clip;

pub const Track = struct {
    clips: std.ArrayList(*Clip),

    pub fn init() @This() {
        return @This(){
            .clips = .empty,
        };
    }
    pub fn deinit(self: *@This(), allocator: std.mem.Allocator) void {
        self.clips.deinit(allocator);
    }

    pub fn addClip(self: *@This(), allocator: std.mem.Allocator, clip: *Clip) !void {
        try self.clips.append(allocator, clip);
    }
};
