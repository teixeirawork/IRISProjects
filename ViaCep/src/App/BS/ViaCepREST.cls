/*
    BUSINESS SERVICE (BS) atua como endpoint REST para consulta de CEP via ViaCep API.
    EXTENDE %CSP.REST para lidar com requisições HTTP RESTful.
    A classe processa requisições de consulta de CEP, chama o serviço ViaCep e retorna os dados formatados.
*/
Class App.BS.ViaCepREST Extends %CSP.REST
{
    
    Parameter UseSession = 0; // Desabilita o uso de sessão  0 = desabilitado, 1 = habilitado

    // Configura o mapeamento da URL para o metodo BuscaCep

    XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
    {
        <Routes>
            <Route Url="/BuscaCEP/:cep" Method="GET" Call="BuscaCEP" />
        </Routes>
    }

    // Método que orquestra a chamada ao BO e gera Resposta JSON

    /// Description
    ClassMethod BuscaCep(pCEP As %String) As %Status
    {
       Set %response.ContentType = "application/json"

       // Cria metodo de requisição

       Set tRequest = ##Class(App.Msg.App.Msg.CEPRequest).%New()
       Set tRequest.CEP = pCEP

       // Chama o BO para o processamento de Lógica

       Set tBO = ##Class(App.BO.ViaCepBO).%New()
       Set tStatus = tBO.OnMessage(tRequest, .tResponse) 

      // Converte a Menssagem de resposta (Ens.Reponse) para JSON

        If $$$ISOK(tStatus){
            Set tOutPut = {}.%fromObject(tResponse)
            // Limpa campos internos do Ens.Response antes de enviar como JSON (Boas Práticas)
            Do tOutPut.%Remove("$$OID")
            Do tOutPut.%Remove("$$MSGID")
            Do tOutPut.%Remove("$$HDR")
            Write tOutPut.%ToJSON()


        } Else {
            // Em caso de erro grave no Framework
            Set tError = {}
            Set tError.Status = 500
            Set tError.Mensagem = $SYSTEM.Status.GetErrorText(tStatus)

            Write tError.%ToJSON()

        }

        Quit $$$OK

    }


}