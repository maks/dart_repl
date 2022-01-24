// Copyright (c) 2016, Andreas 'blackhc' Kirsch. All rights reserved. Use of
// this source code is governed by a BSD-style license that can be found in the
// LICENSE file.
// ignore_for_file: implementation_imports

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/src/dart/scanner/reader.dart';
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/string_source.dart';
import 'package:analyzer/src/generated/parser.dart';

bool isExpression(String code) => _tryParse(
    code, (Parser parser, Token token) => parser.parseExpression(token));

bool isStatement(String code) => _tryParse(code, (Parser parser, Token token) {
      final statement = parser.parseStatement(token);
      if (statement.toString().isEmpty) {
        return null;
      }
      return statement;
    });

bool _tryParse(String code, Function parse) {
  final reader = CharSequenceReader(code);
  final errorListener = BooleanErrorListener();
  final featureSet = FeatureSet.latestLanguageVersion();
  final scanner = Scanner(StringSource(code, ''), reader, errorListener);
  scanner.configureFeatures(
      featureSetForOverriding: featureSet, featureSet: featureSet);
  final token = scanner.tokenize();
  final parser =
      Parser(StringSource(code, ''), errorListener, featureSet: featureSet);
  final node = parse(parser, token) as AstNode;

  return !errorListener.errorReported &&
      node.endToken.next?.type == TokenType.EOF;
}
