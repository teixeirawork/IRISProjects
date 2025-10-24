/* CLASSE DE REQUISIÇÃO PARA O SERVIÇO VIA CEP */

Class Msg.CEPRequest Extends Ens.Request
{

    /// CEP A SER CONSULTADO
    Property CEP As %String(MAXLEN=8);


}