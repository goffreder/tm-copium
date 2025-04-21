// c 2024-03-05
// m 2025-04-14

[Setting category="General" name="Show timer"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

[Setting category="General" name="Show best no-respawn time (resets on map change)"]
bool S_BestCopium = true;

[Setting category="General" name="Show debug window"]
bool S_Debug = false;


[Setting category="Position/Style" name="Position X" min=0.0f max=1.0f]
float S_X = 0.5f;

[Setting category="Position/Style" name="Position Y" min=0.0f max=1.0f]
float S_Y = 0.99f;

[Setting category="Position/Style" name="Show number of respawns after finish"]
bool S_Respawns = true;

[Setting category="Position/Style" name="Show thousandths" description="not perfectly accurate"]
bool S_Thousandths = true;

enum BackgroundOption {
    None,
    OnlyBehindDelta,
    BehindEverything
}

[Setting category="Position/Style" name="Show background"]
BackgroundOption S_Background = BackgroundOption::OnlyBehindDelta;

[Setting category="Position/Style" name="Background color" color]
vec4 S_BackgroundColor = vec4(0.0f, 0.0f, 0.0f, 0.7f);

// [Setting category="Position/Style" name="Background X-padding" min=0.0f max=30.0f]
const float S_BackgroundXPad = 8.0f;

[Setting category="Position/Style" name="Background Y-padding" min=0.0f max=30.0f]
float S_BackgroundYPad = 6.0f;

[Setting category="Position/Style" name="Background corner radius" min=0.0f max=50.0f]
float S_BackgroundRadius = 20.0f;

[Setting category="Position/Style" name="Show delta"]
bool S_Delta = true;

[Setting category="Position/Style" name="Positive delta color" description="slower than PB" color]
vec4 S_PositiveColor = vec4(0.8f, 0.0f, 0.0f, 0.8f);

[Setting category="Position/Style" name="Neutral delta color" description="equal to PB" color]
vec4 S_NeutralColor = vec4(0.7f, 0.7f, 0.7f, 0.8f);

[Setting category="Position/Style" name="Negative delta color" description="faster than PB" color]
vec4 S_NegativeColor = vec4(0.0f, 0.0f, 0.8f, 0.8f);

[Setting category="Position/Style" name="Show drop shadow"]
bool S_Drop = true;

[Setting category="Position/Style" name="Drop shadow color" color]
vec4 S_DropColor = vec4(0.0f, 0.0f, 0.0f, 1.0f);

[Setting category="Position/Style" name="Drop shadow offset" min=1 max=10]
int S_DropOffset = 2;

[Setting category="Position/Style" name="Show medal icons after finish"]
bool S_Medals = true;

#if DEPENDENCY_CHAMPIONMEDALS
[Setting category="Position/Style" name="Champion medal" color]
vec4 S_ChampionColor = vec4(1.0f, 0.267f, 0.467f, 1.0f);
#endif

[Setting category="Position/Style" name="Author medal" color]
vec4 S_AuthorColor = vec4(0.0f, 0.471f, 0.035f, 1.0f);

[Setting category="Position/Style" name="Gold medal" color]
vec4 S_GoldColor = vec4(0.871f, 0.737f, 0.259f, 1.0f);

[Setting category="Position/Style" name="Silver medal" color]
vec4 S_SilverColor = vec4(0.537f, 0.604f, 0.604f, 1.0f);

[Setting category="Position/Style" name="Bronze medal" color]
vec4 S_BronzeColor = vec4(0.604f, 0.4f, 0.259f, 1.0f);


[Setting category="Font" hidden]
Font S_Font = Font::DroidSans_Bold;

[Setting category="Font" hidden]
string S_CustomFont;

[Setting category="Font" hidden]
int S_FontSize = 24;

[Setting category="Font" hidden]
vec4 S_FontColor = vec4(1.0f, 1.0f, 1.0f, 1.0f);

[SettingsTab name="Font" icon="Font" order=1]
void SettingsTab_Font() {
    if (UI::Button("Reset to default")) {
        Meta::PluginSetting@[]@ settings = pluginMeta.GetSettings();
        for (uint i = 0; i < settings.Length; i++) {
            if (settings[i].Category == "Font")
                settings[i].Reset();
        }

        ChangeFont();
    }

    const string userFontFolder = IO::FromDataFolder("Fonts").Replace("\\", "/");

    if (UI::BeginCombo("Style", tostring(S_Font))) {
        Font f;

        for (int i = 0; i < Font::_Droid_End; i++) {
            f = Font(i);
            if (UI::Selectable(tostring(f), S_Font == f)) {
                S_Font = f;
                ChangeFont();
            }
        }

        UI::Separator();

        for (int i = Font::_Droid_End + 1; i < Font::_Montserrat_End; i++) {
            f = Font(i);
            if (UI::Selectable(tostring(f), S_Font == f)) {
                S_Font = f;
                ChangeFont();
            }
        }

        UI::Separator();

        for (int i = Font::_Montserrat_End + 1; i < Font::_Oswald_End; i++) {
            f = Font(i);
            if (UI::Selectable(tostring(f), S_Font == f)) {
                S_Font = f;
                ChangeFont();
            }
        }

        UI::Separator();

        if (UI::Selectable("Custom", S_Font == Font::Custom)) {
            S_Font = Font::Custom;

            if (!IO::FolderExists(userFontFolder))
                IO::CreateFolder(userFontFolder);
            else
                ChangeFont();
        }

        UI::EndCombo();
    }

    if (S_Font == Font::Custom) {
        UI::Indent(scale * 30.0f);

        UI::TextWrapped("Font files (\\$0F0.ttf\\$G) go in");
        UI::SameLine();
        if (UI::TextLink(userFontFolder))
            OpenExplorerPath(userFontFolder);
        if (UI::IsItemHovered()) {
            UI::BeginTooltip();
            UI::Text(Icons::ExternalLink + " open in explorer");
            UI::EndTooltip();
        }

        string[]@ filenames = IO::IndexFolder(userFontFolder, false);
        if (filenames.Length == 0) {
            S_CustomFont = "";
            UI::TextWrapped("\\$FF0Folder is empty, download some fonts!");

        } else {
            if (UI::BeginCombo("File", S_CustomFont)) {
                for (uint i = 0; i < filenames.Length; i++) {
                    const string name = Path::GetFileName(filenames[i]);
                    if (name.EndsWith(".ttf") and UI::Selectable(name, S_CustomFont == name)) {
                        S_CustomFont = name;
                        ChangeFont();
                    }
                }

                UI::EndCombo();
            }
        }

        UI::Indent(scale * -30.0f);
    }

    S_FontSize = UI::SliderInt("Size", S_FontSize, 8, 128);
    if (S_FontSize < 8)
        S_FontSize = 8;
    if (S_FontSize > 128)
        S_FontSize = 128;

    S_FontColor = UI::InputColor4("Color", S_FontColor);
}
