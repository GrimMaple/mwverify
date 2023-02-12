import std.file;
import std.digest : toHexString;

import dlangui;

mixin APP_ENTRY_POINT;

static immutable correct = [0x3D, 0x30, 0x28, 0x0B];
enum addr = 0x5A2D;

enum nameAddr = addr + 4;

string getSavefileName(ubyte[] data)
{
    string ret = "";
    size_t idx = nameAddr;
    while(data[idx] != 0)
    {
        ret ~= cast(char)data[idx];
        idx++;
    }
    return ret;
}

extern (C) int UIAppMain()
{
    Window w = Platform.instance.createWindow("mwverify", null, WindowFlag.Resizable, 400, 200);
    TextWidget wdgt = new TextWidget("main");
    wdgt.text = "Drag & Drop a MW save file";
    wdgt.alignment = Align.Center;
    wdgt.fontSize = 32;
    wdgt.textColor = 0x00FFFFFF;
    w.backgroundColor = 0x00333333;
    w.onFilesDropped = (string[] files){
        if(isDir(files[0]))
        {
            wdgt.text = UIString.fromRaw("Not a Most Wanted savefile!");
            return;
        }
        ubyte[] data = cast(ubyte[])read(files[0]);
        if(data[0] != 0x32 || data[1] != 0x30 || data[2] != 0x43 || data[3] != 0x4D)
        {
            wdgt.text = UIString.fromRaw("Not a Most Wanted savefile!");
            return;
        }
        string name = getSavefileName(data);
        wdgt.fontWeight = 700;
        if(data[addr .. addr + 4] != correct)
        {
            wdgt.text = UIString.fromRaw(name ~ ": WRONG FILE");
            wdgt.textColor = 0x00FF0000;
            return;
        }
        wdgt.text = UIString.fromRaw(name ~ ": CORRECT FILE");
        wdgt.textColor = 0x0000AA00;
        scope(exit)
        {
            w.invalidate();
            wdgt.invalidate();
        }
    };
    w.mainWidget = wdgt;
    w.show();
    return Platform.instance.enterMessageLoop();
}