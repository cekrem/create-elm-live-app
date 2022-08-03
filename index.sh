#!/bin/sh
set -e

project_dir="$1"

mkdir "$project_dir"
cd "$project_dir"

echo "initializing '$project_dir'"
git init > /dev/null

PORT="$PORT"

cat > package.json << EOL
{
  "name": "${project_dir}",
  "version": "1.0.0",
  "author": "$(git config --get user.name) <$(git config --get user.email)>",
  "license": "MIT",
  "scripts": {
    "postinstall": "elm-tooling install",
    "build": "elm make src/Main.elm  --output=public_html/index.html --optimize",
    "dev": "elm-live src/Main.elm -- --debug",
    "start": "http-server public_html --port=$PORT"
  }
}

EOL

cat > .gitignore << EOL
elm-stuff
node_modules
repl-temp-*
elm.js
index.html

EOL

echo "installing dependencies"
npm install --save-dev elm-tooling elm-live > /dev/null
npm install --save http-server > /dev/null

export PATH="$PATH":node_modules/.bin

yes | elm-tooling init > /dev/null
elm-tooling install > /dev/null
yes | elm init > /dev/null
yes | elm install elm/random > /dev/null

cat > src/Main.elm << EOL
module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Random



-- MAIN


main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }



-- MODEL


type alias Model =
  { dieFace : Int
  }


init : () -> (Model, Cmd Msg)
init _ =
  ( Model 1
  , Cmd.none
  )



-- UPDATE


type Msg
  = Roll
  | NewFace Int


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Roll ->
      ( model
      , Random.generate NewFace (Random.int 1 6)
      )

    NewFace newFace ->
      ( Model newFace
      , Cmd.none
      )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h1 [] [ text (String.fromInt model.dieFace) ]
    , button [ onClick Roll ] [ text "Roll" ]
    ]

EOL

echo "'cd $project_dir' and do 'npm run dev' to start hacking!"
