module Request.Helpers exposing (apiUrl)


apiUrl : String -> String
apiUrl str =
    "https://api.youneedabudget.com/v1" ++ str
