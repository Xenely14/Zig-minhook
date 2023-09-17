# Zig-minhook
`Zig-minhook` is a wrapper of of [minhook](https://github.com/TsudaKageyu/minhook).</br>
This library use original minhook library, download binary dependencies before using (MinHook.x86/64.dll and MinHook.x86/64.lib).</br>
You can find minhook dependencies in `dependencies` folder of this repository.
- - - 
# Installation
1. Intall `Zig-minhook`.</br>
    Clone this repository or download it as archive file.

2. Put minhook `dll's` files into folder with your built binary.</br>
    Use `MinHook.x64.dll` for x64 binaries.</br>
    Use `MinHook.x86.dll` for x86_64 binaries.
- - -
# Building and usage
Let's look at example code and build it:
```Zig
const std = @import("std");
const minhook = @import("minhook.zig");

// Function that we will be hooking.
extern "user32" fn MessageBoxA(hwmd: ?*const anyopaque, text: [*:0]const u8, caption: ?[*:0]const u8, box_type: u32) i32;

// This value will fill with original function pointer after creating hook.
// So it can be used to call an original function from detour function.
const MessageBoxASig: type = *fn (?*const anyopaque, [*:0]const u8, ?[*:0]const u8, u32) i32;
var MessageBoxAOriginal: MessageBoxASig = undefined;

// Detour function.
// This function will be triggered when hooked function will be called.
fn MessageBoxADetour(hwnd: ?*const anyopaque, text: [*:0]const u8, caption: ?[*:0]const u8, box_type: u32) i32 {
    std.debug.print("MessageBoxA call arguments:\n", .{});
    std.debug.print("hwnd -> {?s}\ntext -> {s}\ncaption -> {?s}\nbox_type -> {d}", .{ hwnd, text, caption, box_type });

    return MessageBoxAOriginal(hwnd, "This messagebox has been hooked!", "Hooked", box_type);
}

pub fn main() void {
    var hook_inited = minhook.initialize();

    // If you don't want to use original function you just can pass `null` at the last argument.
    var hook_created = minhook.createHook(&MessageBoxA, &MessageBoxADetour, @ptrCast(&MessageBoxAOriginal));

    // Or you can just use `minhook.enableHook(minhook.MH_ALL_HOOKS)` or `minhook.enableHook(null) to enable all hooks at once.`
    var hook_enabled = minhook.enableHook(&MessageBoxA);

    std.debug.print("hook inited -> {s}\n", .{@tagName(hook_inited)});
    std.debug.print("hook created -> {s}\n", .{@tagName(hook_created)});
    std.debug.print("hook enabled -> {s}\n\n", .{@tagName(hook_enabled)});

    // Try to call MessageBoxA with our arguments
    _ = MessageBoxA(null, "Hello, from MessageBoxA", "Success!", 0x40);
}
```

To build it we can use `zig build-exe example.zig -L "dependencies" -O ReleaseSmall -target x86_64-windows-msvc` command.</br>
You can also create `build.zig` file and configure it.</br>

After building our `.exe` file we have to put out minhook `dll's` dependencies into `PATH` system variables folder or our `.exe` folder.</br>
now we can just launch our file and we'll see something that:
![Zig-minhook](https://cdn.discordapp.com/attachments/906988719934963733/1152730078233501756/image.png)
- - -
# TODO
- [ ] Create `loadDependencies` fn, that will automatically load minhook `dll's` into system libraries folder.
