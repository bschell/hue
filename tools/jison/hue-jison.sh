#!/bin/bash
# Licensed to Cloudera, Inc. under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  Cloudera, Inc. licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo "Make sure you install jison first (npm install jison -g)"
echo ""
echo "Generating parser..."

pushd ../../desktop/core/src/desktop/static/desktop/js/autocomplete/jison

# === Autocomplete parser ===
# For quick version of just SELECT statements without value expressions
# cat autocomplete_header.jison sql_main.jison autocomplete_footer.jison > sqlAutocompleteParser.jison
cat autocomplete_header.jison sql_main.jison sql_valueExpression.jison sql_error.jison sql_alter.jison sql_analyze.jison sql_create.jison sql_drop.jison sql_grant.jison sql_insert.jison sql_load.jison sql_set.jison sql_show.jison sql_update.jison sql_use.jison autocomplete_footer.jison > sqlAutocompleteParser.jison

echo "Creating SQL autocomplete parser..."
jison sqlAutocompleteParser.jison sql.jisonlex
grunt uglify:sqlAutocompleteParser
cat license.txt sqlAutocompleteParser.js > ../sqlAutocompleteParser.js
rm sqlAutocompleteParser.jison
rm sqlAutocompleteParser.js

# === Syntax parser ===
cat syntax_header.jison sql_main.jison sql_valueExpression.jison  sql_alter.jison sql_analyze.jison sql_create.jison sql_drop.jison sql_grant.jison sql_insert.jison sql_load.jison sql_set.jison sql_show.jison sql_update.jison sql_use.jison syntax_footer.jison > sqlSyntaxParser.jison

echo "Creating SQL syntax parser..."
jison sqlSyntaxParser.jison sql.jisonlex
# Workaround for a parser bug where it reports the location of the previous token on error (pull-request submitted for jison)
# We're also adding a ruleId to the parser error composed of the last two stack ID's and used for suppressing errors in the UI
sed -i '' 's/loc: yyloc,/loc: lexer.yylloc, ruleId: stack.slice(stack.length - 2, stack.length).join(''),/' sqlSyntaxParser.js
grunt uglify:sqlSyntaxParser
cat license.txt sqlSyntaxParser.js > ../sqlSyntaxParser.js
rm sqlSyntaxParser.jison
rm sqlSyntaxParser.js

# === Statement parser ===
echo "Creating SQL statements parser..."
jison sqlStatementsParser.jison
grunt uglify:sqlStatementsParser
cat license.txt sqlStatementsParser.js > ../sqlStatementsParser.js
rm sqlStatementsParser.js

# === Global Search parser ===
echo "Creating Global Search parser..."
jison globalSearchParser.jison
grunt uglify:globalSearchParser
cat license.txt globalSearchParser.js > ../globalSearchParser.js
rm globalSearchParser.js

# === SOLR Expression parser ===
echo "Creating SOLR Expression parser..."
jison solrExpressionParser.jison
grunt uglify:solrExpressionParser
cat license.txt solrExpressionParser.js > ../solrExpressionParser.js
rm solrExpressionParser.js

popd
echo "Done!"
