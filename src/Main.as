void Main() {
}

void Notify(const string &in msg) {
    UI::ShowNotification(Meta::ExecutingPlugin().Name, msg);
    trace("Notified: " + msg);
}

void NotifyError(const string &in msg) {
    warn(msg);
    UI::ShowNotification(Meta::ExecutingPlugin().Name + ": Error", msg, vec4(.9, .3, .1, .3), 15000);
}

void NotifyWarning(const string &in msg) {
    warn(msg);
    UI::ShowNotification(Meta::ExecutingPlugin().Name + ": Warning", msg, vec4(.9, .6, .2, .3), 15000);
}

const string PluginIcon = Icons::PlayCircle;
const string MenuTitle = "\\$3f3" + PluginIcon + "\\$z " + Meta::ExecutingPlugin().Name;

// show the window immediately upon installation
[Setting hidden]
bool ShowWindow = true;

/** Render function called every frame intended only for menu items in `UI`. */
void RenderMenu() {
    if (UI::MenuItem(MenuTitle, "", ShowWindow)) {
        ShowWindow = !ShowWindow;
    }
}

bool isAbsolutePath = false;
string pluginPath, relativePath;
Meta::PluginType pluginType = Meta::PluginType::Unknown;

/** Render function called every frame.
*/
void Render() {
    if (!ShowWindow) return;
    vec2 size = vec2(500, 300);
    vec2 pos = (vec2(Draw::GetWidth(), Draw::GetHeight()) - size) / 2.;
    UI::SetNextWindowSize(int(size.x), int(size.y), UI::Cond::FirstUseEver);
    UI::SetNextWindowPos(int(pos.x), int(pos.y), UI::Cond::FirstUseEver);
    UI::PushStyleColor(UI::Col::FrameBg, vec4(.2, .2, .2, .5));
    if (UI::Begin(MenuTitle, ShowWindow)) {
        bool changed = false;
        pluginPath = UI::InputText("Plugin ID (Folder Name)", pluginPath, changed);
        isAbsolutePath = UI::Checkbox("Absolute path?", isAbsolutePath);

        if (changed) {
            pluginPath = pluginPath.Trim();
            relativePath = IO::FromDataFolder("Plugins/" + pluginPath);
        }
        bool isOp = pluginPath.EndsWith(".op");
        bool isZip = pluginPath.EndsWith(".zip");
        pluginType = (isOp || isZip) ? Meta::PluginType::Zip : Meta::PluginType::Folder;

        UI::Text("Loading from: " + (isAbsolutePath ? pluginPath : relativePath));
        UI::Text("Plugin type: " + tostring(pluginType));

        if (UI::Button("Load Plugin Now")) {
            startnew(RunLoadPlugin);
        }
    }
    UI::End();
    UI::PopStyleColor();
}

void RunLoadPlugin() {
    string path = isAbsolutePath ? pluginPath : relativePath;
    if (pluginType == Meta::PluginType::Folder) {
        if (!(path.EndsWith("/") || path.EndsWith("\\"))) {
            path += "/";
        }
    }
    isAbsolutePath ? Meta::LoadPlugin(path, Meta::PluginSource::Unknown, pluginType)
                   : Meta::LoadPlugin(path, Meta::PluginSource::UserFolder, pluginType);
}




void AddSimpleTooltip(const string &in msg) {
    if (UI::IsItemHovered()) {
        UI::BeginTooltip();
        UI::Text(msg);
        UI::EndTooltip();
    }
}
