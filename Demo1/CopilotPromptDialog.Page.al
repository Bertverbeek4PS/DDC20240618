page 70104 "Copilot Demo1"
{
    PageType = PromptDialog;
    Extensible = false;
    ApplicationArea = All;
    SourceTable = "AI History 4PS";
    SourceTableTemporary = true;
    DataCaptionExpression = 'This is written by copilot';
    Caption = 'Copilot Fps';
    IsPreview = true;
    PromptMode = Prompt;

    layout
    {
        area(Prompt)
        {

            field(input; UserInput)
            {
                ApplicationArea = All;
                ShowCaption = false;
                MultiLine = true;
                InstructionalText = 'Here you can enter the country...';
            }
        }
        area(Content)
        {
            field(Response; Response)
            {
                ShowCaption = false;
                MultiLine = true;
                ApplicationArea = All;
            }
        }
        area(PromptOptions)
        {
            field(Tone; ToneOption)
            {
                Caption = 'Tone';
                ToolTip = 'Specifies the style of the generated text.';
            }
            field(TextFormat; TextFormatOption)
            {
                Caption = 'Format';
                ToolTip = 'Specifies the length and format of the generated text.';
            }
            field(Emphasis; EmphasisOption)
            {
                Caption = 'Emphasis';
                ToolTip = 'Specifies a quality to emphasis in the generated text.';
            }
        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Generate';
                trigger OnAction()
                var
                    CopilotDemo1: Codeunit "Copilot Demo1";
                begin
                    Response := CopilotDemo1.Generate(UserInput);
                    SaveHistory();
                    //CurrPage.Update();
                end;
            }
            systemaction(OK)
            {
                Caption = 'Confirm';
                ToolTip = 'Add suggestion to the database.';
            }
            systemaction(Cancel)
            {
                Caption = 'Discard';
                ToolTip = 'Discard suggestion proposed by Dynamics 365 Copilot.';
            }
            systemaction(Regenerate)
            {
                Caption = 'Regenerate';
                ToolTip = 'Regenerate proposal with Dynamics 365 Copilot.';
                trigger OnAction()
                var
                    CopilotDemo1: Codeunit "Copilot Demo1";
                begin
                    Response := CopilotDemo1.Generate(Response);
                    SaveHistory();
                    //CurrPage.Update();
                end;
            }
        }
        area(PromptGuide)
        {
            action(predictCapital)
            {
                ApplicationArea = All;
                Caption = 'Predict capital';

                trigger OnAction()
                begin
                    UserInput := 'What is the capitcal of [country].';
                end;
            }
            action(predictDDC)
            {
                ApplicationArea = All;
                Caption = 'Predict DDC';

                trigger OnAction()
                begin
                    UserInput := 'What is the DDC.';
                end;
            }
        }
    }
    var
        UserInput: Text;
        Response: Text;
        ToneOption: Enum "Entity Text Tone";
        TextFormatOption: Enum "Entity Text Format";
        EmphasisOption: Enum "Entity Text Emphasis";

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = CloseAction::OK then
            // Do something
            Message('The result is stored in the database.');
    end;

    local procedure SaveHistory();
    var
        OutStream: OutStream;
    begin
        Rec.Init();
        Rec."Entry No." := Rec.Count + 1;
        Rec.Tone := ToneOption;
        Rec.TextFormat := TextFormatOption;
        Rec.Emphasis := EmphasisOption;
        Rec."Generated Text".CreateOutStream(OutStream);
        OutStream.WriteText(Response);
        Rec.Insert();
    end;
}