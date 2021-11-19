///////////////////////////////////////////////////////////////////////////
// Cria��o...........: 15-03-2001
// Ultima modifica��o: 04-06-2002
// Sistema...........: Controle de Acesso - Testes
// Analistas.........: Marilene Esquiavoni & Denny Paulista Azevedo Filho
// Desenvolvedores...: Marilene Esquiavoni & Denny Paulista Azevedo Filho
// Copyright.........: Marilene Esquiavoni & Denny Paulista Azevedo Filho
//////////////////////////////////////////////////////////////////////////

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, Mask, StdCtrls, Spin, Menus, DBTables;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    MaskEdit1: TMaskEdit;
    MaskEdit2: TMaskEdit;
    MaskEdit3: TMaskEdit;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    Memo1: TMemo;
    ListBox1: TListBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    MainMenu1: TMainMenu;
    Arquivo1: TMenuItem;
    Opcao11: TMenuItem;
    Opcao21: TMenuItem;
    Opcao31: TMenuItem;
    Editar1: TMenuItem;
    Opcao12: TMenuItem;
    Opcao22: TMenuItem;
    Opcao32: TMenuItem;
    Opcao41: TMenuItem;
    Ferramentas1: TMenuItem;
    Opcao13: TMenuItem;
    Opcao23: TMenuItem;
    Sair1: TMenuItem;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

procedure ArmazenaAcesso(Frm: TForm);
procedure VerificaAcesso(Frm: TForm; User: String);

implementation

{$R *.DFM}


//
//  Esta procedure serve apenas para obter os componentes colocados no
//  Form e cadastr�-los na tabela de acesso.  Deve ser rodada apenas
//  uma �nica vez no evento OnCreate do Form.
//
procedure ArmazenaAcesso(Frm: TForm);
type
  Vetor12 = array[0..11] of String;

var
  Tbl : TTable;

  Cmp,
  Ctr : Integer;

//  Constante contendo os objetos que ser�o controlados
//  Adicione outros objetos que voc� quiser neste vetor
//
//  Em princ�pio est�o faltando todos os componentes de
//  banco de dados (TDBEdit, TDBGrid, etc).
Const
  CTRL:  Vetor12 = ( 'TButton',      'TBitBtn',  'TEdit',     'TMaskEdit',
                     'TSpeedButton', 'TMemo',    'TComboBox', 'TCheckBox',
                     'TRadioButton', 'TListBox', 'TSpinEdit', 'TMenuItem' );
begin
  Tbl := TTable.Create(nil);
  Tbl.DatabaseName := ExtractFileDir(ParamStr(0));
  Tbl.TableType := ttParadox;
  Tbl.TableName := 'ACESSO';

  try
    Tbl.Open;

    with Form1 do
      for Cmp := 0 to ComponentCount - 1 do
          for Ctr := 0 to High(CTRL) do
              if UpperCase(Components[Cmp].ClassName) = UpperCase(CTRL[Ctr]) then begin
                 Tbl.Append;
                 Tbl.FieldByName('ACS_GRUPO').AsString    := Name;
                 Tbl.FieldByName('ACS_SUBGRUPO').AsString := Components[Cmp].Name;
                 Tbl.FieldByName('ACS_PERFIL').AsString   := 'GERENTE';
                 Tbl.FieldByName('ACS_ENABLED').AsString  := 'S';
                 Tbl.FieldByName('ACS_VISIBLE').AsString  := 'S';
                 Tbl.Post;

                 Tbl.Append;
                 Tbl.FieldByName('ACS_GRUPO').AsString    := Name;
                 Tbl.FieldByName('ACS_SUBGRUPO').AsString := Components[Cmp].Name;
                 Tbl.FieldByName('ACS_PERFIL').AsString   := 'VENDEDOR';
                 Tbl.FieldByName('ACS_ENABLED').AsString  := 'S';
                 Tbl.FieldByName('ACS_VISIBLE').AsString  := 'S';
                 Tbl.Post;

                 Break;
              end;
  finally
    Tbl.Close;
    Tbl.Free;
  end;
end;

procedure VerificaAcesso(Frm: TForm; User: String);
var
  Qry : TQuery;
  Per : String;
  Cmp : Integer;

begin
  Qry := TQuery.Create(nil);
  Qry.DatabaseName := ExtractFileDir(ParamStr(0));

  // Busca o perfil do usu�rio
  Qry.Sql.Add('SELECT ACS_PERFIL FROM USERS.DB');
  Qry.Sql.Add('WHERE USR_LOGIN = "'+User+'"');

  try
    Qry.Open;

    Per := Qry.FieldByName('ACS_PERFIL').AsString;

    //  Se o perfil n�o foi encontrado � necess�rio desabilitar tudo !
    if Per = '' then with Frm do
       for Cmp := 0 to ComponentCount - 1 do
           try
             if Components[Cmp] is TMenuItem then
                (Components[Cmp] as TMenuItem).Enabled := False
             else
                (Components[Cmp] as TControl).Enabled  := False
           except
           end
    else begin
      //  Perfil encontrado. Selecionar acesso para este perfil.
      Qry.Close;
      Qry.Sql.Clear;

      Qry.Sql.Add('SELECT * FROM ACESSO');
      Qry.Sql.Add('WHERE ACS_PERFIL = "'+Per+'" AND');
      Qry.Sql.Add('ACS_GRUPO = "'+Frm.Name+'"');
      Qry.Open;

      with Frm do
        while not Qry.Eof do begin
          // Se o objeto for um TMenuItem � necess�rio fazer o trabalho manualmente
          // os outros objetos podem ser acessados pela sua deriva��o do TControl
          if FindComponent(Qry.FieldByName('ACS_SUBGRUPO').AsString) is TMenuItem then begin
             (FindComponent(Qry.FieldByName('ACS_SUBGRUPO').AsString) as TMenuItem).Enabled := (Qry.FieldByName('ACS_ENABLED').AsString = 'S');
             (FindComponent(Qry.FieldByName('ACS_SUBGRUPO').AsString) as TMenuItem).Visible := (Qry.FieldByName('ACS_VISIBLE').AsString = 'S');
          end else begin
             (FindComponent(Qry.FieldByName('ACS_SUBGRUPO').AsString) as TControl).Enabled := (Qry.FieldByName('ACS_ENABLED').AsString = 'S');
             (FindComponent(Qry.FieldByName('ACS_SUBGRUPO').AsString) as TControl).Visible := (Qry.FieldByName('ACS_VISIBLE').AsString = 'S');
          end;

          Qry.Next;
        end;
    end;
  except
    // Ocorreu algum erro. Por medida de seguran�a deve-se desabilitar tudo !
    with Frm do
       for Cmp := 0 to ComponentCount - 1 do
           try
             if Components[Cmp] is TMenuItem then
                (Components[Cmp] as TMenuItem).Enabled := False
             else
                (Components[Cmp] as TControl).Enabled  := False;
           except
           end;
  end;

  Qry.Close;
  Qry.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//  ArmazenaAcesso(Form1);
  VerificaAcesso(Form1, 'JOSE');
end;

end.
