const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.addModule("minhook", .{
        .source_file = .{ .path = "minhook.zig" },
        .dependencies = &[_]std.Build.ModuleDependency{},
    });
}
