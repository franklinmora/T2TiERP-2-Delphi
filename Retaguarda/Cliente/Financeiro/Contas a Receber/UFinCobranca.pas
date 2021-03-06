{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cobran�a

The MIT License

Copyright: Copyright (C) 2016 T2Ti.COM

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

The author may be contacted at:
t2ti.com@gmail.com</p>

@author Albert Eije (t2ti.com@gmail.com)
@version 2.0
******************************************************************************* }
unit UFinCobranca;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Atributos,
  Dialogs, UTelaCadastro, DB, DBClient, Menus, StdCtrls, ExtCtrls, Buttons, Grids,
  DBGrids, JvExDBGrids, JvDBGrid, JvDBUltimGrid, ComCtrls, FinCobrancaVO,
  FinCobrancaController, Tipos, Constantes, LabeledCtrls, JvToolEdit,
  Mask, JvExMask, JvBaseEdits, Math, StrUtils, ActnList, Generics.Collections,
  RibbonSilverStyleActnCtrls, ActnMan, ToolWin, ActnCtrls, ShellApi,
  System.Actions, Controller;

type
  [TFormDescription(TConstantes.MODULO_CONTAS_RECEBER, 'Cobran�a')]

  TFFinCobranca = class(TFTelaCadastro)
    ActionManager: TActionManager;
    ActionConsultarParcelas: TAction;
    PanelParcelas: TPanel;
    PanelMestre: TPanel;
    EditIdCliente: TLabeledCalcEdit;
    EditCliente: TLabeledEdit;
    EditDataAcertoPagamento: TLabeledDateEdit;
    EditValorTotal: TLabeledCalcEdit;
    EditDataContato: TLabeledDateEdit;
    DSParcelaReceber: TDataSource;
    CDSParcelaReceber: TClientDataSet;
    EditHoraContato: TLabeledMaskEdit;
    ActionMarcarDataHoraContato: TAction;
    EditTelefoneContato: TLabeledMaskEdit;
    PageControlItensLancamento: TPageControl;
    tsParcelasSimuladoAcordo: TTabSheet;
    PanelItensLancamento: TPanel;
    GridParcelas: TJvDBUltimGrid;
    CDSParcelaReceberID: TIntegerField;
    CDSParcelaReceberID_FIN_PARCELA_RECEBER: TIntegerField;
    CDSParcelaReceberID_FIN_COBRANCA: TIntegerField;
    CDSParcelaReceberVALOR_JURO_SIMULADO: TFMTBCDField;
    CDSParcelaReceberVALOR_MULTA_SIMULADO: TFMTBCDField;
    CDSParcelaReceberVALOR_RECEBER_SIMULADO: TFMTBCDField;
    CDSParcelaReceberVALOR_JURO_ACORDO: TFMTBCDField;
    CDSParcelaReceberVALOR_MULTA_ACORDO: TFMTBCDField;
    CDSParcelaReceberVALOR_RECEBER_ACORDO: TFMTBCDField;
    CDSParcelaReceberPERSISTE: TStringField;
    CDSParcelaReceberID_FIN_LANCAMENTO_RECEBER: TIntegerField;
    CDSParcelaReceberDATA_VENCIMENTO: TDateTimeField;
    CDSParcelaReceberVALOR_PARCELA: TFMTBCDField;
    tsParcelasVencidas: TTabSheet;
    PanelParcelasVencidas: TPanel;
    GridParcelasVencidas: TJvDBUltimGrid;
    CDSParcelasVencidas: TClientDataSet;
    DSParcelasVencidas: TDataSource;
    ActionToolBar2: TActionToolBar;
    ActionCalcularMultaJuros: TAction;
    EditValorTotalJuros: TLabeledCalcEdit;
    EditValorTotalMulta: TLabeledCalcEdit;
    EditValorTotalAtrasado: TLabeledCalcEdit;
    ActionSimularValores: TAction;
    ActionGeraNovoLancamento: TAction;
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure GridParcelasKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CDSParcelaReceberAfterEdit(DataSet: TDataSet);
    procedure CDSParcelaReceberBeforeDelete(DataSet: TDataSet);
    procedure CDSParcelaReceberAfterPost(DataSet: TDataSet);
    procedure EditIdClienteKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionMarcarDataHoraContatoExecute(Sender: TObject);
    procedure ActionConsultarParcelasExecute(Sender: TObject);
    procedure ActionCalcularMultaJurosExecute(Sender: TObject);
    procedure CDSParcelasVencidasBeforePost(DataSet: TDataSet);
    procedure ActionSimularValoresExecute(Sender: TObject);
    procedure CDSParcelaReceberBeforePost(DataSet: TDataSet);
    procedure ActionGeraNovoLancamentoExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridParaEdits; override;
    procedure LimparCampos; override;

    // Controles CRUD
    function DoInserir: Boolean; override;
    function DoEditar: Boolean; override;
    function DoExcluir: Boolean; override;
    function DoSalvar: Boolean; override;

    procedure ConfigurarLayoutTela;
  end;

var
  FFinCobranca: TFFinCobranca;

implementation

uses ULookup, Biblioteca, UDataModule, PessoaVO, PessoaController,
  FinParcelaReceberVO, FinParcelaReceberController, ContaCaixaVO, ContaCaixaController,
  ViewPessoaClienteVO, ViewPessoaClienteController, FinCobrancaParcelaReceberVO,
  ViewFinLancamentoReceberVO, ViewFinLancamentoReceberController;
{$R *.dfm}

{$REGION 'Infra'}
procedure TFFinCobranca.FormCreate(Sender: TObject);
var
  Filtro: String;
begin
  ClasseObjetoGridVO := TFinCobrancaVO;
  ObjetoController := TFinCobrancaController.Create;

  inherited;

  // Configura a Grid das parcelas vencidas
  ConfiguraCDSFromVO(CDSParcelasVencidas, TViewFinLancamentoReceberVO);
  ConfiguraGridFromVO(GridParcelasVencidas, TViewFinLancamentoReceberVO);
end;

procedure TFFinCobranca.LimparCampos;
begin
  inherited;
  CDSParcelaReceber.EmptyDataSet;
end;

procedure TFFinCobranca.ConfigurarLayoutTela;
begin
  PanelEdits.Enabled := True;

  if StatusTela = stNavegandoEdits then
  begin
    PanelMestre.Enabled := False;
    PanelItensLancamento.Enabled := False;
  end
  else
  begin
    PanelMestre.Enabled := True;
    PanelItensLancamento.Enabled := True;
  end;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFinCobranca.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdCliente.SetFocus;
  end;
end;

function TFFinCobranca.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdCliente.SetFocus;
  end;
end;

function TFFinCobranca.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      TController.ExecutarMetodo('FinCobrancaController.TFinCobrancaController', 'Exclui', [IdRegistroSelecionado], 'DELETE', 'Boolean');
      Result := TController.RetornoBoolean;
    except
      Result := False;
    end;
  end
  else
  begin
    Result := False;
  end;

  if Result then
    TController.ExecutarMetodo('FinCobrancaController.TFinCobrancaController', 'Consulta', [Trim(Filtro), Pagina.ToString, False], 'GET', 'Lista');
end;

function TFFinCobranca.DoSalvar: Boolean;
var
  ParcelaReceber: TFinCobrancaParcelaReceberVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TFinCobrancaVO.Create;

      TFinCobrancaVO(ObjetoVO).IdCliente := EditIdCliente.AsInteger;
      TFinCobrancaVO(ObjetoVO).ClienteNome := EditCliente.Text;
      TFinCobrancaVO(ObjetoVO).DataContato := EditDataContato.Date;
      TFinCobrancaVO(ObjetoVO).HoraContato := EditHoraContato.Text;
      TFinCobrancaVO(ObjetoVO).TelefoneContato := EditTelefoneContato.Text;
      TFinCobrancaVO(ObjetoVO).DataAcertoPagamento := EditDataAcertoPagamento.Date;
      TFinCobrancaVO(ObjetoVO).TotalReceberNaData := EditValorTotal.Value;

      // Parcelas
      /// EXERCICIO - TENTE IMPLEMENTAR OS DADOS DA LISTA DE DETALHES DE ACORDO COM O NOVO MODELO PROPOSTO NA INFRA
      TFinCobrancaVO(ObjetoVO).ListaCobrancaParcelaReceberVO := TObjectList<TFinCobrancaParcelaReceberVO>.Create;
      CDSParcelaReceber.DisableControls;
      CDSParcelaReceber.First;
      while not CDSParcelaReceber.Eof do
      begin
        if (CDSParcelaReceberPERSISTE.AsString = 'S') or (CDSParcelaReceberID.AsInteger = 0) then
        begin
          ParcelaReceber := TFinCobrancaParcelaReceberVO.Create;
          ParcelaReceber.Id := CDSParcelaReceberID.AsInteger;
          ParcelaReceber.IdFinCobranca := TFinCobrancaVO(ObjetoVO).Id;
          ParcelaReceber.IdFinLancamentoReceber := CDSParcelaReceberID_FIN_LANCAMENTO_RECEBER.AsInteger;
          ParcelaReceber.IdFinParcelaReceber := CDSParcelaReceberID_FIN_PARCELA_RECEBER.AsInteger;
          ParcelaReceber.DataVencimento := CDSParcelaReceberDATA_VENCIMENTO.AsDateTime;
          ParcelaReceber.ValorParcela := CDSParcelaReceberVALOR_PARCELA.AsExtended;
          ParcelaReceber.ValorJuroSimulado := CDSParcelaReceberVALOR_JURO_SIMULADO.AsExtended;
          ParcelaReceber.ValorJuroAcordo := CDSParcelaReceberVALOR_JURO_ACORDO.AsExtended;
          ParcelaReceber.ValorMultaSimulado := CDSParcelaReceberVALOR_MULTA_SIMULADO.AsExtended;
          ParcelaReceber.ValorMultaAcordo := CDSParcelaReceberVALOR_MULTA_ACORDO.AsExtended;
          ParcelaReceber.ValorReceberSimulado := CDSParcelaReceberVALOR_RECEBER_SIMULADO.AsExtended;
          ParcelaReceber.ValorReceberAcordo := CDSParcelaReceberVALOR_RECEBER_ACORDO.AsExtended;

          TFinCobrancaVO(ObjetoVO).ListaCobrancaParcelaReceberVO.Add(ParcelaReceber);
        end;

        CDSParcelaReceber.Next;
      end;
      CDSParcelaReceber.EnableControls;

      if StatusTela = stInserindo then
      begin
        TController.ExecutarMetodo('FinCobrancaController.TFinCobrancaController', 'Insere', [TFinCobrancaVO(ObjetoVO)], 'PUT', 'Lista');
      end
      else if StatusTela = stEditando then
      begin
        if TFinCobrancaVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TController.ExecutarMetodo('FinCobrancaController.TFinCobrancaController', 'Altera', [TFinCobrancaVO(ObjetoVO)], 'POST', 'Boolean');
        end
        else
          Application.MessageBox('Nenhum dado foi alterado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      end;
    except
      Result := False;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFFinCobranca.EditIdClienteKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
begin
  if Key = VK_F1 then
  begin
    if EditIdCliente.Value <> 0 then
      Filtro := 'ID = ' + EditIdCliente.Text
    else
      Filtro := 'ID=0';

    try
      EditIdCliente.Clear;
      EditCliente.Clear;
      if not PopulaCamposTransientes(Filtro, TViewPessoaClienteVO, TViewPessoaClienteController) then
        PopulaCamposTransientesLookup(TViewPessoaClienteVO, TViewPessoaClienteController);
      if CDSTransiente.RecordCount > 0 then
      begin
        EditIdCliente.Text := CDSTransiente.FieldByName('ID').AsString;
        EditCliente.Text := CDSTransiente.FieldByName('NOME').AsString;
      end
      else
      begin
        Exit;
        EditDataContato.SetFocus;
      end;
    finally
      CDSTransiente.Close;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFFinCobranca.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;

procedure TFFinCobranca.GridParaEdits;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    ObjetoVO := TFinCobrancaVO(TController.BuscarObjeto('FinCobrancaController.TFinCobrancaController', 'ConsultaObjeto', ['ID=' + IdRegistroSelecionado.ToString], 'GET'));
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdCliente.AsInteger := TFinCobrancaVO(ObjetoVO).IdCliente;
    EditCliente.Text := TFinCobrancaVO(ObjetoVO).ClienteNome;
    EditDataContato.Date := TFinCobrancaVO(ObjetoVO).DataContato;
    EditHoraContato.Text := TFinCobrancaVO(ObjetoVO).HoraContato;
    EditTelefoneContato.Text := TFinCobrancaVO(ObjetoVO).TelefoneContato;
    EditDataAcertoPagamento.Date := TFinCobrancaVO(ObjetoVO).DataAcertoPagamento;
    EditValorTotal.Value := TFinCobrancaVO(ObjetoVO).TotalReceberNaData;

    // Preenche as grids internas com os dados das Listas que vieram no objeto
    // Parcelas
    TController.TratarRetorno<TFinCobrancaParcelaReceberVO>(TFinCobrancaVO(ObjetoVO).ListaCobrancaParcelaReceberVO, True, True, CDSParcelaReceber);

    // Limpa as listas para comparar posteriormente se houve inclus�es/altera��es e subir apenas o necess�rio para o servidor
    TFinCobrancaVO(ObjetoVO).ListaCobrancaParcelaReceberVO.Clear;

    // Serializa o objeto para consultar posteriormente se houve altera��es
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
  ConfigurarLayoutTela;
end;

procedure TFFinCobranca.GridParcelasKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  If Key = VK_RETURN then
    GridParcelas.SelectedIndex := GridParcelas.SelectedIndex + 1;
end;

procedure TFFinCobranca.CDSParcelaReceberAfterEdit(DataSet: TDataSet);
begin
  CDSParcelaReceberPERSISTE.AsString := 'S';
end;

procedure TFFinCobranca.CDSParcelaReceberAfterPost(DataSet: TDataSet);
begin
  if CDSParcelaReceberDATA_VENCIMENTO.AsString = '' then
    CDSParcelaReceber.Delete;
end;

procedure TFFinCobranca.CDSParcelaReceberBeforeDelete(DataSet: TDataSet);
begin
  if CDSParcelaReceberID.AsInteger > 0 then
    TFinParcelaReceberController.Exclui(CDSParcelaReceberID.AsInteger);
end;

procedure TFFinCobranca.CDSParcelasVencidasBeforePost(DataSet: TDataSet);
begin
  /// EXERCICIO: SE CONSIDERAR NECESSARIO, PERMITA QUE O USU�RIO SELECIONE SE DESEJA O CALCULO COM JUROS SIMPLES OU COMPOSTOS (USE COMBOBOXES)

  CDSParcelasVencidas.FieldByName('VALOR_JURO').AsExtended := (CDSParcelasVencidas.FieldByName('VALOR_PARCELA').AsExtended * (CDSParcelasVencidas.FieldByName('TAXA_JURO').AsExtended / 30) / 100) * (Now - CDSParcelasVencidas.FieldByName('DATA_VENCIMENTO').AsDateTime);
  CDSParcelasVencidas.FieldByName('VALOR_MULTA').AsExtended := CDSParcelasVencidas.FieldByName('VALOR_PARCELA').AsExtended * (CDSParcelasVencidas.FieldByName('TAXA_MULTA').AsExtended / 100);
end;

procedure TFFinCobranca.CDSParcelaReceberBeforePost(DataSet: TDataSet);
begin
  CDSParcelaReceber.FieldByName('VALOR_RECEBER_SIMULADO').AsExtended := CDSParcelaReceber.FieldByName('VALOR_PARCELA').AsExtended +
                                                                        CDSParcelaReceber.FieldByName('VALOR_JURO_SIMULADO').AsExtended +
                                                                        CDSParcelaReceber.FieldByName('VALOR_MULTA_SIMULADO').AsExtended;
end;

{$ENDREGION}

{$REGION 'Actions'}
procedure TFFinCobranca.ActionCalcularMultaJurosExecute(Sender: TObject);
var
  TotalAtraso, Total, Juros, Multa: Extended;
begin

  /// EXERCICIO: SE CONSIDERAR NECESSARIO, ARMAZENE NO BANCO DE DADOS OS TOTAIS DE JUROS E MULTAS

  Juros := 0;
  Multa := 0;
  Total := 0;
  TotalAtraso := 0;
  //
  CDSParcelaReceber.EmptyDataSet;
  //
  CDSParcelasVencidas.DisableControls;
  CDSParcelasVencidas.First;
  while not CDSParcelasVencidas.Eof do
  begin
    CDSParcelaReceber.Append;
    CDSParcelaReceber.FieldByName('ID_FIN_LANCAMENTO_RECEBER').AsInteger := CDSParcelasVencidas.FieldByName('ID_LANCAMENTO_RECEBER').AsInteger;
    CDSParcelaReceber.FieldByName('ID_FIN_PARCELA_RECEBER').AsInteger := CDSParcelasVencidas.FieldByName('ID_PARCELA_RECEBER').AsInteger;
    CDSParcelaReceber.FieldByName('DATA_VENCIMENTO').AsDateTime := CDSParcelasVencidas.FieldByName('DATA_VENCIMENTO').AsDateTime;
    CDSParcelaReceber.FieldByName('VALOR_PARCELA').AsExtended := CDSParcelasVencidas.FieldByName('VALOR_PARCELA').AsExtended;
    CDSParcelaReceber.FieldByName('VALOR_JURO_SIMULADO').AsExtended := CDSParcelasVencidas.FieldByName('VALOR_JURO').AsExtended;
    CDSParcelaReceber.FieldByName('VALOR_JURO_ACORDO').AsExtended := CDSParcelasVencidas.FieldByName('VALOR_JURO').AsExtended;
    CDSParcelaReceber.FieldByName('VALOR_MULTA_SIMULADO').AsExtended := CDSParcelasVencidas.FieldByName('VALOR_MULTA').AsExtended;
    CDSParcelaReceber.FieldByName('VALOR_MULTA_ACORDO').AsExtended := CDSParcelasVencidas.FieldByName('VALOR_MULTA').AsExtended;
    CDSParcelaReceber.FieldByName('VALOR_RECEBER_SIMULADO').AsExtended := CDSParcelasVencidas.FieldByName('VALOR_PARCELA').AsExtended +
                                                                        CDSParcelasVencidas.FieldByName('VALOR_JURO').AsExtended +
                                                                        CDSParcelasVencidas.FieldByName('VALOR_MULTA').AsExtended;
    CDSParcelaReceber.FieldByName('VALOR_RECEBER_ACORDO').AsExtended := CDSParcelaReceber.FieldByName('VALOR_RECEBER_SIMULADO').AsExtended;
    CDSParcelaReceber.Post;
    TotalAtraso := TotalAtraso + CDSParcelaReceber.FieldByName('VALOR_PARCELA').AsExtended;
    Total := Total + CDSParcelaReceber.FieldByName('VALOR_RECEBER_SIMULADO').AsExtended;
    Juros := Juros + CDSParcelaReceber.FieldByName('VALOR_JURO_SIMULADO').AsExtended;
    Multa := Multa + CDSParcelaReceber.FieldByName('VALOR_MULTA_SIMULADO').AsExtended;
    CDSParcelasVencidas.Next;
  end;
  CDSParcelasVencidas.First;
  CDSParcelasVencidas.EnableControls;
  //
  EditValorTotal.Value := Total;
  EditValorTotalJuros.Value := Juros;
  EditValorTotalMulta.Value := Multa;
  EditValorTotalAtrasado.Value := TotalAtraso;
end;

procedure TFFinCobranca.ActionConsultarParcelasExecute(Sender: TObject);
var
  Filtro: String;
begin
  /// EXERCICIO: ENCONTRE O ERRO NO FILTRO E CORRIJA.

  TViewFinLancamentoReceberController.SetDataSet(CDSParcelasVencidas);
  Filtro := 'SITUACAO_PARCELA=' + QuotedStr('01') + ' and DATA_VENCIMENTO < ' + QuotedStr(DataParaTexto(Now));
  TController.ExecutarMetodo('ViewFinLancamentoReceberController.TViewFinLancamentoReceberController', 'Consulta', [Filtro, '0', False], 'GET', 'Lista');
end;

procedure TFFinCobranca.ActionMarcarDataHoraContatoExecute(Sender: TObject);
begin
  EditDataContato.Date := Now;
  EditHoraContato.Text := FormatDateTime('hh:mm:ss', Now);
end;

procedure TFFinCobranca.ActionSimularValoresExecute(Sender: TObject);
var
  Total, Juros, Multa: Extended;
begin
  /// EXERCICIO: CRIE CAMPOS CALCULADOS PARA VER A DIFEREN�A ENTRE O SIMULADO E O ACORDADO

  Juros := 0;
  Multa := 0;
  Total := 0;

  CDSParcelaReceber.DisableControls;
  CDSParcelaReceber.First;
  while not CDSParcelaReceber.Eof do
  begin
    Total := Total + CDSParcelaReceber.FieldByName('VALOR_RECEBER_SIMULADO').AsExtended;
    Juros := Juros + CDSParcelaReceber.FieldByName('VALOR_JURO_SIMULADO').AsExtended;
    Multa := Multa + CDSParcelaReceber.FieldByName('VALOR_MULTA_SIMULADO').AsExtended;
    CDSParcelaReceber.Next;
  end;
  CDSParcelaReceber.First;
  CDSParcelaReceber.EnableControls;
  //
  EditValorTotal.Value := Total;
  EditValorTotalJuros.Value := Juros;
  EditValorTotalMulta.Value := Multa;
end;

procedure TFFinCobranca.ActionGeraNovoLancamentoExecute(Sender: TObject);
begin
  /// EXERCICIO: GERE UM NOVO LAN�AMENTO COM BASE NO QUE FOI ACORDADO
  Application.MessageBox('Lan�amento efetuado com sucesso.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
  BotaoCancelar.Click;
end;

/// EXERCICIO: CRIE UMA ACTION QUE PERMITA O USUARIO BAIXAR OS VALORES DOS JUROS/MULTAS COM BASE NUM PERCENTUAL FORNECIDO

{$ENDREGION}

end.
