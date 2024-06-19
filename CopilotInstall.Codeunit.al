codeunit 70102 "Copilot Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        CopilotDemo1: Codeunit "Copilot Demo1";
        CopilotDemo2: Codeunit "Copilot Demo2";
        CopilotDemo3: Codeunit "Copilot Demo3";
    begin
        CopilotDemo1.RegisterCapability();
        CopilotDemo2.RegisterCapability();
        CopilotDemo3.RegisterCapability();
    end;
}