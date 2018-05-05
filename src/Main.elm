module Main exposing (Model, Msg, update, view, subscriptions, init)

import Data.AccessToken as AccessToken exposing (AccessToken(..), decoder)
import Data.Budget exposing (Budget)
import Data.Session as Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import Json.Decode as Decode exposing (Value)
import Ports
import Views.Assets exposing (assets)
import Views.Modal as Modal


-- INIT


main : Program Value Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Value -> ( Model, Cmd Msg )
init val =
    ( { modelInitialValue | session = decodeSessionFromJson val }, Cmd.none )


decodeSessionFromJson : Value -> Session
decodeSessionFromJson json =
    let
        maybeSession =
            json
                |> Decode.decodeValue Decode.string
                |> Result.toMaybe
                |> Maybe.andThen (Decode.decodeString Session.decoder >> Result.toMaybe)
    in
        case maybeSession of
            Just session ->
                session

            Nothing ->
                modelInitialValue.session



-- MODEL


type alias Model =
    { session : Session
    , isRequestingAccessToken : Bool
    , budgets : List Budget
    }


modelInitialValue : Model
modelInitialValue =
    { session = { apiUrl = "", token = Nothing }
    , isRequestingAccessToken = False
    , budgets = []
    }



-- UPDATE


type Msg
    = RequestAccessToken
    | UpdateAccessToken (Maybe AccessToken)
    | Disconnect
    | HandleBudgetsResponse


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestAccessToken ->
            ( { model | isRequestingAccessToken = True }, Ports.requestAccessToken () )

        UpdateAccessToken token ->
            ( { model | session = { apiUrl = model.session.apiUrl, token = token } }, Cmd.none )

        Disconnect ->
            ( model, Ports.disconnect () )

        HandleBudgetsResponse ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.onAccessTokenChange (\val -> UpdateAccessToken (Result.toMaybe (Decode.decodeValue AccessToken.decoder val)))



-- VIEW


view : Model -> Html Msg
view model =
    case model.session.token of
        Nothing ->
            welcomePage model

        Just token ->
            chooseBudgetPage model


chooseBudgetPage : Model -> Html Msg
chooseBudgetPage model =
    viewPage chooseBudgetContent model


chooseBudgetContent : Model -> Html Msg
chooseBudgetContent model =
    section [ class "o-choose-budget" ]
        [ viewToolbar model
        , header [ class "text-center" ]
            [ h1 [] [ text "Choose a Budget" ]
            ]
        ]


welcomePage : Model -> Html Msg
welcomePage model =
    viewPage welcomeContent model


welcomeContent : Model -> Html Msg
welcomeContent model =
    section [ class "o-welcome-content" ]
        [ header [ class "text-center" ]
            [ h1 [ class "display-3" ]
                [ img [ src assets.logo ] []
                , text "Snowball"
                , em [ class "mx-2" ] [ text " for " ]
                , strong [] [ text "YNAB" ]
                ]
            , p [ class "lead" ] [ text "Debt payment strategies for your YNAB budget." ]
            ]
        , div [ class "text-center py-4" ]
            [ loaderButton "Connecting to YNAB..." "Connect to YNAB" model.isRequestingAccessToken [ class "btn btn-primary btn-lg", onClick RequestAccessToken ]
            ]
        ]


loaderButton : String -> String -> Bool -> List (Html.Attribute msg) -> Html msg
loaderButton loadingLabel label isLoading attrs =
    button (List.concat [ attrs, [ disabled isLoading ] ])
        (if isLoading then
            [ span [ class "far fa-snowflake fa-spin" ] []
            , text (" " ++ loadingLabel)
            ]
         else
            [ text label ]
        )


viewPage : (Model -> Html Msg) -> Model -> Html Msg
viewPage content model =
    div [ class "container" ]
        [ content model
        , viewFooter model
        ]


viewToolbar : Model -> Html Msg
viewToolbar model =
    div []
        [ ul [ class "nav justify-content-end" ]
            [ li [ class "nav-item" ] [ button [ class "nav-link btn btn-link btn-sm", onClick Disconnect ] [ text "Disconnect" ] ]
            ]
        ]



-- FOOTER


viewFooter : Model -> Html Msg
viewFooter model =
    footer [ class "o-site-footer mt-4" ]
        [ ul [ class "nav justify-content-center" ]
            [ li [ class "nav-item" ] [ button [ class "nav-link btn btn-link", attribute "data-toggle" "modal", attribute "data-target" "#terms-modal" ] [ text "Terms and Conditions" ] ]
            , li [ class "nav-item" ] [ button [ class "nav-link btn btn-link", attribute "data-toggle" "modal", attribute "data-target" "#disclaimer-modal" ] [ text "Disclaimer" ] ]
            , li [ class "nav-item" ] [ button [ class "nav-link btn btn-link", attribute "data-toggle" "modal", attribute "data-target" "#privacy-policy-modal" ] [ text "Privacy Policy" ] ]
            , li [ class "nav-item" ] [ a [ class "nav-link", href "https://github.com/guzart/snowball" ] [ text "Source Code" ] ]
            ]
        , viewTermsModal
        , viewDisclaimerModal
        , viewPrivacyPolicyModal
        ]


viewTermsModal : Html Msg
viewTermsModal =
    Modal.view
        { id = "terms-modal"
        , title = Just (h5 [] [ text "Terms and Conditions (\"Terms\")" ])
        , body = Just (div [ property "innerHTML" (Encode.string """
            <p>Last updated: May 01, 2018</p>
            <p>Please read these Terms and Conditions ("Terms", "Terms and Conditions") carefully before using the https://snowball-ynab.firebaseapp.com/ website (the "Service") operated by Snowball for YNAB ("us", "we", or "our").</p>
            <p>Your access to and use of the Service is conditioned on your acceptance of and compliance with these Terms. These Terms apply to all visitors, users and others who access or use the Service.</p>
            <p>By accessing or using the Service you agree to be bound by these Terms. If you disagree with any part of the terms then you may not access the Service.</p>
            <h2 class="h4">Links To Other Web Sites</h2>
            <p>Our Service may contain links to third-party web sites or services that are not owned or controlled by Snowball for YNAB.</p>
            <p>Snowball for YNAB has no control over, and assumes no responsibility for, the content, privacy policies, or practices of any third party web sites or services. You further acknowledge and agree that Snowball for YNAB shall not be responsible or liable, directly or indirectly, for any damage or loss caused or alleged to be caused by or in connection with use of or reliance on any such content, goods or services available on or through any such web sites or services.</p>
            <p>We strongly advise you to read the terms and conditions and privacy policies of any third-party web sites or services that you visit.</p>
            <h2 class="h4">Governing Law</h2>
            <p>These Terms shall be governed and construed in accordance with the laws of Mexico, without regard to its conflict of law provisions.</p>
            <p>Our failure to enforce any right or provision of these Terms will not be considered a waiver of those rights. If any provision of these Terms is held to be invalid or unenforceable by a court, the remaining provisions of these Terms will remain in effect. These Terms constitute the entire agreement between us regarding our Service, and supersede and replace any prior agreements we might have between us regarding the Service.</p>
            <h2 class="h4">Changes</h2>
            <p>We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material we will try to provide at least 30 days notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.</p>
            <p>By continuing to access or use our Service after those revisions become effective, you agree to be bound by the revised terms. If you do not agree to the new terms, please stop using the Service.</p>
            <h2 class="h4">Contact Us</h2>
            <p>If you have any questions about these Terms, please contact us.</p>
        """) ] [])
        , footer = Nothing
        }


viewDisclaimerModal : Html Msg
viewDisclaimerModal =
    Modal.view
        { id = "disclaimer-modal"
        , title = Just (h5 [] [ text "Disclaimer" ])
        , body = Just (div [ property "innerHTML" (Encode.string """
            <p>Last updated: May 01, 2018</p>
            <p>The information contained on https://snowball-ynab.firebaseapp.com website (the "Service") is for general information purposes only.</p>
            <p>Snowball for YNAB assumes no responsibility for errors or omissions in the contents on the Service.</p>
            <p>In no event shall Snowball for YNAB be liable for any special, direct, indirect, consequential, or incidental damages or any damages whatsoever, whether in an action of contract, negligence or other tort, arising out of or in connection with the use of the Service or the contents of the Service. Snowball for YNAB reserves the right to make additions, deletions, or modification to the contents on the Service at any time without prior notice.</p>
            <p>Snowball for YNAB does not warrant that the website is free of viruses or other harmful components.</p>
        """) ] [])
        , footer = Nothing
        }


viewPrivacyPolicyModal : Html Msg
viewPrivacyPolicyModal =
    Modal.view
        { id = "privacy-policy-modal"
        , title = Just (h5 [] [ text "Privacy Policy" ])
        , body = Just (div [ property "innerHTML" (Encode.string """
            <p>Effective date: May 01, 2018</p>
            <p>Snowball for YNAB ("us", "we", or "our") operates the https://snowball-ynab.firebaseapp.com/ website (the "Service").</p>
            <p>This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service and the choices you have associated with that data.</p>
            <p>We use your data to provide and improve the Service. By using the Service, you agree to the collection and use of information in accordance with this policy. Unless otherwise defined in this Privacy Policy, terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, accessible from https://snowball-ynab.firebaseapp.com/</p>
            <h2 class="h4">Information Collection And Use</h2>
            <p>We collect several different types of information for various purposes to provide and improve our Service to you.</p>
            <h3 class="h5">Types of Data Collected</h3>
            <h4 class="h6">Personal Data</h4>
            <p>While using our Service, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you ("Personal Data"). Personally identifiable information may include, but is not limited to:</p>
            <ul>
                <li>Cookies and Usage Data</li>
            </ul>
            <h4 class="h6">Usage Data</h4>
            <p>We may also collect information how the Service is accessed and used ("Usage Data"). This Usage Data may include information such as your computer's Internet Protocol address (e.g. IP address), browser type, browser version, the pages of our Service that you visit, the time and date of your visit, the time spent on those pages, unique device identifiers and other diagnostic data.</p>
            <h4 class="h6">Tracking &amp; Cookies Data</h4>
            <p>We use cookies and similar tracking technologies to track the activity on our Service and hold certain information.</p>
            <p>Cookies are files with small amount of data which may include an anonymous unique identifier. Cookies are sent to your browser from a website and stored on your device. Tracking technologies also used are beacons, tags, and scripts to collect and track information and to improve and analyze our Service.</p>
            <p>You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent. However, if you do not accept cookies, you may not be able to use some portions of our Service.</p>
            <p>Examples of Cookies we use:</p>
            <ul>
                <li><strong>Session Cookies.</strong> We use Session Cookies to operate our Service.</li>
                <li><strong>Preference Cookies.</strong> We use Preference Cookies to remember your preferences and various settings.</li>
                <li><strong>Security Cookies.</strong> We use Security Cookies for security purposes.</li>
            </ul>
            <h2 class="h4">Use of Data</h2>
            <p>Snowball for YNAB uses the collected data for various purposes:</p>
            <ul>
                <li>To provide and maintain the Service</li>
                <li>To notify you about changes to our Service</li>
                <li>To allow you to participate in interactive features of our Service when you choose to do so</li>
                <li>To provide customer care and support</li>
                <li>To provide analysis or valuable information so that we can improve the Service</li>
                <li>To monitor the usage of the Service</li>
                <li>To detect, prevent and address technical issues</li>
            </ul>
            <h2 class="h4">Transfer Of Data</h2>
            <p>Your information, including Personal Data, may be transferred to — and maintained on — computers located outside of your state, province, country or other governmental jurisdiction where the data protection laws may differ than those from your jurisdiction.</p>
            <p>If you are located outside Mexico and choose to provide information to us, please note that we transfer the data, including Personal Data, to Mexico and process it there.</p>
            <p>Your consent to this Privacy Policy followed by your submission of such information represents your agreement to that transfer.</p>
            <p>Snowball for YNAB will take all steps reasonably necessary to ensure that your data is treated securely and in accordance with this Privacy Policy and no transfer of your Personal Data will take place to an organization or a country unless there are adequate controls in place including the security of your data and other personal information.</p>
            <h2 class="h4">Disclosure Of Data</h2>
            <h3 class="h5">Legal Requirements</h3>
            <p>Snowball for YNAB may disclose your Personal Data in the good faith belief that such action is necessary to:</p>
            <ul>
                <li>To comply with a legal obligation</li>
                <li>To protect and defend the rights or property of Snowball for YNAB</li>
                <li>To prevent or investigate possible wrongdoing in connection with the Service</li>
                <li>To protect the personal safety of users of the Service or the public</li>
                <li>To protect against legal liability</li>
            </ul>
            <h2 class="h4">Security Of Data</h2>
            <p>The security of your data is important to us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.</p>
            <h2 class="h4">Service Providers</h2>
            <p>We may employ third party companies and individuals to facilitate our Service ("Service Providers"), to provide the Service on our behalf, to perform Service-related services or to assist us in analyzing how our Service is used.</p>
            <p>These third parties have access to your Personal Data only to perform these tasks on our behalf and are obligated not to disclose or use it for any other purpose.</p>
            <h2 class="h4">Links To Other Sites</h2>
            <p>Our Service may contain links to other sites that are not operated by us. If you click on a third party link, you will be directed to that third party's site. We strongly advise you to review the Privacy Policy of every site you visit.</p>
            <p>We have no control over and assume no responsibility for the content, privacy policies or practices of any third party sites or services.</p>
            <h2 class="h4">Children's Privacy</h2>
            <p>Our Service does not address anyone under the age of 13 ("Children").</p>
            <p>We do not knowingly collect personally identifiable information from anyone under the age of 13. If you are a parent or guardian and you are aware that your Children has provided us with Personal Data, please contact us. If we become aware that we have collected Personal Data from children without verification of parental consent, we take steps to remove that information from our servers.</p>
            <h2 class="h4">Changes To This Privacy Policy</h2>
            <p>We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.</p>
            <p>We will let you know via email and/or a prominent notice on our Service, prior to the change becoming effective and update the "effective date" at the top of this Privacy Policy.</p>
            <p>You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.</p>
            <h2 class="h4">Contact Us</h2>
            <p>If you have any questions about this Privacy Policy, please contact us:</p>
            <ul>
                <li>By visiting this page: https://github.com/guzart/snowball/issues</li>
            </ul>
        """) ] [])
        , footer = Nothing
        }
