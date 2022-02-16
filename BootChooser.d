module bootchooser;

import std.stdio;
import std.file;
import std.process;
import std.string;
import std.conv;
import std.net.curl;

// Copyright 2022 kaigonzalez
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

extern (C) char* readline(const char* prompt);

string PROGNAME = "bootchooser";

void pprint(string text) {
    writeln(PROGNAME ~ ": " ~ text);
}

void psherror(string text, bool fatal = false) {
    if (fatal) {
        writeln(PROGNAME ~ ": \033[33mfatal: " ~ text ~ "\033[0m");
    } else {
        writeln(PROGNAME ~ ": \033[31;1merror: " ~ text ~ "\033[0m");
    }
}

void loadbinary(string[] bin) {
    auto krnl=spawnProcess(bin);

    if (wait(krnl) != 0) {
        pprint("process ended, management done");
    }

}

void doboot(string[] pml = ["bootchooser"]) {
    try {
    PROGNAME = pml[0];
    if (exists("./system/.registered")) {
        auto f = File("system/.registered", "r");
        string term = f.readln();
        f.close();

        loadbinary(["./machines/" ~ term ~ ".kernel"]);
    } else {
        assert(!exists("./system/.registered"));

        pprint("which boot manager would you like to install?");

        string input = std.conv.to!string(readline(cast(const char*)"setup $ "));

        if (input == "default" || input == "def" || input == "d") {
            pprint("current default is powpck1: loading powpck1.kernel");

            if (!exists("machines/powpck1.kernel")) {
                psherror("Could not load powpck1.kernel, please make sure you've built the POWPC 
                kernel from the kernels/ directory.", true);
                psherror("This requires Python installed (for the sort kernel script).", true);
            } else {
                if (!exists("system")) {
                    mkdir("system");
                }
                
                auto f = File("system/.registered", "w");
                f.writeln("powpck1");
                f.close();

                loadbinary(["machines/powpck1.kernel"]);
            }
        } else {
            if (indexOf(input, "d") != -1) {
                pprint("warning: \"default\" \"def\" or \"d\" required.");
            } else if (input == "help") {
                pprint("Bootchooser is a utility that aids in finding the right task for your Kux installation.");
                pprint("Bootchooser stores no information.");
            } else {
                pprint("Is this a local kernel? (can it be installed from a \"machines\" folder?");
            }
        }
    }
    } catch (Exception e) {
        psherror("Exception occurred in main process! " ~ to!string(e));
    }
}