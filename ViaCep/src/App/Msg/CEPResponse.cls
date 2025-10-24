/// CLASSE DE RESPOSTA PARA O SERVIÇO VIA CEP

Class App.Msg.CEPResponse Extends Ens.Response
{

    /// DADOS DO ENDEREÇO CONSULTADO
    Property Logradouro As %String;
    Property Bairro As %String;
    Property Localidade As %String;
    Property UF As %String(MAXLEN=2);
    Property Complemento As %String;

    /*STATUS DA CONSULTA
        200: Sucesso; 
        404: Não encontrado; 
        500: Erro interno do servidor
    */
    Property Status As %Integer;
    Property Mensagem As %String;

}