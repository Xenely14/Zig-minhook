const std = @import("std");
const minhook = @import("minhook.zig");

// Function that we will be hooking.
extern "user32" fn MessageBoxA(hwmd: ?*const anyopaque, text: [*:0]const u8, caption: ?[*:0]const u8, box_type: u32) callconv(.C) i32;

// This value will fill with original function pointer after creating hook.
// So it can be used to call an original function from detour function.
const MessageBoxASig: type = *fn (?*const anyopaque, [*:0]const u8, ?[*:0]const u8, u32) callconv(.C) i32;
var MessageBoxAOriginal: MessageBoxASig = undefined;

// Detour function.
// This function will be triggered when hooked function will be called.
fn MessageBoxADetour(hwnd: ?*const anyopaque, text: [*:0]const u8, caption: ?[*:0]const u8, box_type: u32) callconv(.C) i32 {
    std.debug.print("MessageBoxA call arguments:\n", .{});
    std.debug.print("hwnd -> {?s}\ntext -> {s}\ncaption -> {?s}\nbox_type -> {d}", .{ hwnd, text, caption, box_type });

    return MessageBoxAOriginal(hwnd, "This messagebox has been hooked!", "Hooked", box_type);
}

pub fn main() void {
    var hook_inited = minhook.initialize();

    // If you don't want to use original function you just can pass `null` at the last argument.
    var hook_created = minhook.createHook(&MessageBoxA, &MessageBoxADetour, @ptrCast(&MessageBoxAOriginal));

    // Or you can just use `minhook.enableHook(minhook.MH_ALL_HOOKS)` or `minhook.enableHook(minhook.null) to enable all hooks at once.`
    var hook_enabled = minhook.enableHook(&MessageBoxA);

    std.debug.print("hook inited -> {s}\n", .{@tagName(hook_inited)});
    std.debug.print("hook created -> {s}\n", .{@tagName(hook_created)});
    std.debug.print("hook enabled -> {s}\n\n", .{@tagName(hook_enabled)});

    // Try to call MessageBoxA with our arguments
    _ = MessageBoxA(null, "Hello, from MessageBoxA", "Success!", 0x40);
}
