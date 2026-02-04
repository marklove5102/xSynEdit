object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'SynEdit PopupMenu & SearchPanel Demo'
  ClientHeight = 600
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Size = 8
  KeyPreview = True
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  DesignSize = (
    900
    600)
  TextHeight = 13
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      900
      50)
    object Label1: TLabel
      Left = 424
      Top = 14
      Width = 59
      Height = 13
      Caption = 'Highlighter:'
    end
    object BtnOpenFile: TButton
      Left = 10
      Top = 10
      Width = 100
      Height = 30
      Caption = 'Open File...'
      TabOrder = 0
      OnClick = BtnOpenFileClick
    end
    object BtnSaveFile: TButton
      Left = 116
      Top = 10
      Width = 100
      Height = 30
      Caption = 'Save File...'
      TabOrder = 1
      OnClick = BtnSaveFileClick
    end
    object ComboHighlighter: TComboBox
      Left = 489
      Top = 10
      Width = 120
      Height = 21
      Style = csDropDownList
      TabOrder = 2
      OnChange = ComboHighlighterChange
    end
    object ChkReadOnly: TCheckBox
      Left = 624
      Top = 13
      Width = 97
      Height = 17
      Caption = 'Read Only'
      TabOrder = 3
      OnClick = ChkReadOnlyClick
    end
    object BtnAbout: TButton
      Left = 785
      Top = 10
      Width = 100
      Height = 30
      Anchors = [akTop, akRight]
      Caption = 'About...'
      TabOrder = 4
      OnClick = BtnAboutClick
    end
  end
  object PanelMain: TPanel
    Left = 0
    Top = 50
    Width = 900
    Height = 527
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object SynEdit1: TSynEdit
      Left = 0
      Top = 0
      Width = 900
      Height = 527
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Consolas'
      Font.Pitch = fpFixed
      Font.Size = 10
      Font.Style = []
      TabOrder = 0
      OnStatusChange = SynEdit1StatusChange
      CodeFolding.GutterShapeSize = 11
      CodeFolding.CollapsedLineColor = clGrayText
      CodeFolding.FolderBarLinesColor = clGrayText
      CodeFolding.IndentGuidesColor = clGray
      CodeFolding.IndentGuides = True
      CodeFolding.ShowCollapsedLine = False
      CodeFolding.ShowHintMark = True
      FontSmoothing = fsmNone
      Gutter.Font.Charset = DEFAULT_CHARSET
      Gutter.Font.Color = clWindowText
      Gutter.Font.Height = -11
      Gutter.Font.Name = 'Consolas'
      Gutter.Font.Pitch = fpFixed
      Gutter.Font.Size = 9
      Gutter.Font.Style = []
      Gutter.ShowLineNumbers = True
      Gutter.Bands = <
        item
          Kind = gbkMarks
          Width = 13
        end
        item
          Kind = gbkLineNumbers
        end
        item
          Kind = gbkFold
        end
        item
          Kind = gbkTrackChanges
        end
        item
          Kind = gbkMargin
          Width = 3
        end>
      Options = [eoAutoIndent, eoDragDropEditing, eoEnhanceEndKey, eoGroupUndo, eoShowScrollHint, eoSmartTabDelete, eoSmartTabs, eoTabsToSpaces]
      TabWidth = 4
      WantTabs = True
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 577
    Width = 900
    Height = 23
    Panels = <
      item
        Width = 150
      end
      item
        Width = 100
      end
      item
        Width = 100
      end
      item
        Width = 100
      end
      item
        Width = 50
      end>
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'pas'
    Filter =
      'Pascal Files (*.pas)|*.pas|C++ Files (*.cpp;*.h)|*.cpp;*.h|SQL ' +
      'Files (*.sql)|*.sql|XML Files (*.xml)|*.xml|All Files (*.*)|*.*'
    Left = 232
    Top = 8
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'pas'
    Filter =
      'Pascal Files (*.pas)|*.pas|C++ Files (*.cpp)|*.cpp|SQL Files (*' +
      '.sql)|*.sql|XML Files (*.xml)|*.xml|All Files (*.*)|*.*'
    Left = 272
    Top = 8
  end
  object SynPasSyn1: TSynPasSyn
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    Left = 320
    Top = 8
  end
  object SynCppSyn1: TSynCppSyn
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    Left = 360
    Top = 8
  end
  object SynSQLSyn1: TSynSQLSyn
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    CommentAttri.Foreground = clGreen
    Left = 400
    Top = 8
  end
  object SynXMLSyn1: TSynXMLSyn
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    WantBracesParsed = False
    Left = 440
    Top = 8
  end
end
