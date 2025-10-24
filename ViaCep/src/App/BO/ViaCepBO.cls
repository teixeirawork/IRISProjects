/* Business Operation: Responsável por executar a chamada HTTP externa ao ViaCEP */
Class App.BO.ViaCepBO Extends Ens.BusinessOperation
{

    // DEFINE ADAPTADOR PARA AMBIENTE PRODUCTION (EMBORA USEMOS %Net.HttpRequest, É UMA BOA PRATICA DEFINIR UM ADAPTADOR)

    
    Parameter ADPTER = "Ens.Net.HttpClientAdapter";
    Parameter INNVOCATION = "Queue";

    // MÉTODO QUE PROCESSA A MENSAGEM E CHAMA O SERVICO VIA CEP
    Method OnMessage(pRequest As App.Msg.CEPRequest, Output pResponse As App.Msg.CEPResponse) As %Status
    {
        
        // Instanciar a classe CEPResponse
        Set pResponse = ##class(App.Msg.CEPResponse).%New()

        // Instanciar o cliente  HTTP
        Set httpRequest = ##class(%Net.HttpRequest).%New()

    
        // Preparar Requisição HTTP
        Set httpRequest.Server = "viacep.com.br"
        Set httpRequest.Port = 80
        Set cepLimpo = $Translate(pRequest.CEP, "-.","") // Remove caracteres especiais do CEP
        Set urlViaCep = "/ws/" _ cepLimpo _ "/json/"
    

        Set tSC = httpRequest.Get(urlViaCep) // Executa a requisição HTTP GET

        // Verificar o status da resposta HTTP
        If $$$ISOK(tSC) {
            
            // Processa o Json de retorno
            Set jsonResponse = httpRequest.HttpResponse.Data // Lê o corpo da resposta HTTP
            Set dynObj = jsonResponse.%FromJSON() // Converte o JSON para um objeto dinâmico

            // Verifica erro interno do ViaCEP
            If $ISOBJECT(dynObj) && $Property(dynObj,"erro") { // Se existir a propriedade "erro", o CEP não foi encontrado
                Set pResponse.Status = 404
                Set pResponse.Mensagem = "CEP não encontrado ou formato inválido."
            } Else {
                // Mapeamento dos campos JSON para a Mensagem de resposta
                Set pResponse.Logradouro = $Property(dynObj.logradouro, "logradouro")
                Set pResponse.Bairro = $Property(dynObj.bairro, "bairro")
                Set pResponse.Localidade = $Property(dynObj.localidade, "localidade")
                Set pResponse.UF = $Property(dynObj.uf, "uf")
                Set pResponse.Complemento = $Property(dynObj.complemento, "complemento")
                Set pResponse.Status = 200
                Set pResponse.Mensagem = "Consulta realizada sucesso"

            }
        } Else {
            // Loga o erro de comunicação no Production Monitor (Boa pratica)
            DO $system.OBJ.LogMessage("Falha HTTP ViaCEP. Status: " _ httpRequest.HttpResponse.StatusCode, "ERROR", "API-VIACEP")
            Set pResponse.Status = 500
            Set pResponse.Mensagem = "Erro interno do servidor ou falha ao consultar o ViaCEP."

    }

        Quit $$$OK
    }

}