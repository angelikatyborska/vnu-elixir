# Overview

[![angelikatyborska](https://circleci.com/gh/angelikatyborska/vnu-elixir.svg?style=shield)](https://circleci.com/gh/angelikatyborska/vnu-elixir)
![Hex.pm](https://img.shields.io/hexpm/v/vnu)
![Hex.pm](https://img.shields.io/hexpm/dt/vnu)
![Hex.pm](https://img.shields.io/hexpm/l/vnu)
[![Coverage Status](https://coveralls.io/repos/github/angelikatyborska/vnu-elixir/badge.svg?branch=master)](https://coveralls.io/github/angelikatyborska/vnu-elixir?branch=master)

An Elixir client for [the Nu HTML Checker (v.Nu)](https://validator.w3.org/nu/).

![Expected HTML document to be valid, but got 1 error. Attribute html-is-awesome not allowed on element body at this point.](https://raw.github.com/angelikatyborska/vnu-elixir/main/assets/overview.png)

[v.Nu](https://validator.w3.org/nu/) is a document validity checker used by the W3C.
It offers validating HTML, CSS, and SVG documents.

This library brings that functionality to Elixir by using the Checker's JSON API.
It offers ExUnit assertions for validating dynamic content in tests, Mix tasks for validating static content, and general purpose functions to fulfill other needs.
