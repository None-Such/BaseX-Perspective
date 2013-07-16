(:~
 : Admin console module with Info view and Facet View 
 :)
module namespace page = 'http://basex.org/modules/AdminConsole';

declare %restxq:path("")
        %output:method("xhtml")
        %output:omit-xml-declaration("no")
        %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
        %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:start() {
  let $title := 'i4BaseX Admin Console' return
  <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>{ $title }</title>
      <script src="/basex-admin-console/3rd-party/jquery-1.9.1.min.js"></script>
      <script src="/basex-admin-console/js/d3-v3-patched.js"></script>
      <script src="/basex-admin-console/js/patches/string-patch.js"></script>
      <script src="/basex-admin-console/js/patches/numbers-format.js"></script>
      <script src="/basex-admin-console/js/patches/has-horizontal-scrollbar.js"></script>
      <script src="/basex-admin-console/js/basex-facets.js"></script>
      <script src="/basex-admin-console/js/bezier-tree.js"></script>
      <script src="/basex-admin-console/js/simple-tree.js"></script>
      <script src="/basex-admin-console/js/cheatsheet-content.js"></script>
      
      <script src="/basex-admin-console/3rd-party/bootstrap/js/bootstrap.min.js"></script>
      <script src="/basex-admin-console/3rd-party/syntaxhighlighter-3.0.83/js/shCorePatch.js"></script>
      <script src="/basex-admin-console/3rd-party/syntaxhighlighter-3.0.83/js/shBrushXml.js"></script>
      <script src="/basex-admin-console/3rd-party/syntaxhighlighter-3.0.83/js/shBrushXquery.js"></script>
      <script src="/basex-admin-console/3rd-party/codemirror-3.12/lib/codemirror.js"></script>
      <script src="/basex-admin-console/3rd-party/codemirror-3.12/mode/xquery/xquery.js"></script>
      <script src="/basex-admin-console/3rd-party/codemirror-3.12/addon/searchcursor.js"></script>
      <script src="/basex-admin-console/3rd-party/codemirror-ui/js/codemirror-ui.js" type="text/javascript"></script>
      <script src="/basex-admin-console/3rd-party/ace/ace.js" type="text/javascript"></script>
      <script src="/basex-admin-console/3rd-party/ace/mode-xquery.js" type="text/javascript"></script>

      <link rel="stylesheet" type="text/css" href="/basex-admin-console/3rd-party/codemirror-ui/css/codemirror-ui.css" media="screen" />
      <link rel="stylesheet" type="text/css" href="/basex-admin-console/3rd-party/codemirror-3.12/lib/codemirror.css"></link>
      <link rel="stylesheet" type="text/css" href="/basex-admin-console/3rd-party/bootstrap/css/bootstrap.min.custom.css"/>
      <link rel="stylesheet" type="text/css" href="/basex-admin-console/css/basex-facets.css"/>
      <link rel="stylesheet" type="text/css" href="/basex-admin-console/3rd-party/syntaxhighlighter-3.0.83/css/shCore.css"/>
      <link rel="stylesheet" type="text/css" href="/basex-admin-console/3rd-party/syntaxhighlighter-3.0.83/css/shThemeDefault.css"/>
    </head>
    <body>
      <div class="navbar">
        <div class="navbar-inner">
          <a class="brand" href="#">BaseX Admin Console v1.0</a>
        </div>
      </div>
      <div class="container-fluid">
        <div class="row-fluid">
          <div class="span3 bordered-right" id="side-bar">
            <div id="side-bar-contents">
              <img src="/basex-admin-console/img/BaseX.png" alt="BaseX" id="logo"></img>
              <!--Sidebar content-->
              
              <div class="accordion" id="dbs-accordions">
              {
                for $db in db:list()
                return  
                  <div class="accordion-group">
                    <div class="accordion-heading">
                      <a class="accordion-toggle" data-toggle="collapse" data-parent="#dbs-accordions" href="#{$db}">
                        {$db}
                        <!-- Creation of info and facets xml on page load -->
                        {file:write(concat('../webapp/basex-admin-console/xml/',concat($db,'_info.xml')),db:info($db))}

                        {file:write(concat('../webapp/basex-admin-console/xml/',concat($db,'_facets.xml')),index:facets($db))}
                      </a>
                    </div>
                    <div id="{$db}" class="accordion-body collapse">
                      <div class="accordion-inner">
                        <label class="radio">
                          <input type="radio" name="dbOptionsRadios" id="info-{$db}" value="info" db-name="{$db}"/>
                          Info
                        </label>
                        <label class="radio">
                          <input type="radio" name="dbOptionsRadios" id="facets-{$db}" value="facets" db-name="{$db}"/>
                          Facets
                        </label>
                        <div class="facets-controls-div">
                          <!-- Facets controls per db -->
                          <label class="radio">
                            <input type="radio" name="facets-controls" class="elementsOnly" value="option3" db-name="{$db}"/>Elements
                          </label>
                          <label class="radio">
                            <input type="radio" name="facets-controls" class="elementsAndAttributes" value="option2" db-name="{$db}"/>
                            <span style="inline-block">Elements &amp; Attributes</span>
                          </label>                          
                          <label class="radio">
                            <input type="radio" name="facets-controls" class="allNodes" value="option1" db-name="{$db}"/>
                            Elements &amp; Attributes &amp; Values 
                          </label>
                        </div>
                        <label class="radio">
                          <input type="radio" name="dbOptionsRadios" id="query-{$db}" value="query" db-name="{$db}"/>
                          XQuery
                        </label>
                      </div>
                    </div>
                  </div>
              }
              </div>
            </div>
            <div class="span1" id="side-bar-control">
              <span class="controls" id="toggleSidebar"></span>
            </div>
          </div>
          
          <div class="span9 bordered-right" id="content">
            <div id="chart">
              <div class="tabbable" id="tree-tabs">
                <ul class="nav nav-tabs">
                  <li class="active"><a href="#bezier-tree" data-toggle="tab" id="bezier-tree-tab">Bézier Tree</a></li>
                  <li><a href="#classic-tree" data-toggle="tab" id="classic-tree-tab">Classic Tree</a></li>
                </ul>
                <div class="tab-content">
                  <div class="tab-pane active" id="bezier-tree">
                    <div id="topScroll">
                      <div id="dummyContent"></div>
                    </div>
                    <div id="treeChart"></div>
                  </div>
                  <div class="tab-pane" id="classic-tree">
                    Classic Tree
                  </div>
                </div>
              </div>
            </div>
            <div id="info"></div>

            <div class="tabbable" id="query"> <!-- Only required for left/right tabs -->
              <ul class="nav nav-tabs">
                <li class="active"><a href="#xquery-codemirror-tab" data-toggle="tab">xQuery</a></li>
                <li><a href="#xquery-aceeditor-tab" data-toggle="tab">Ace Editor</a></li>
                <li><a href="#cheat-sheet-tab" data-toggle="tab">Cheat Sheet</a></li>
              </ul>
              <div class="tab-content">
                <div class="tab-pane active" id="xquery-codemirror-tab">
                  <input id="xquery-code-mirror-submit" type="button" value="Submit query" responsePreID="query-response-codemirror" />
                  <br/>
                  <textarea id="xquery-textarea" rows="8" cols="40"></textarea>
                  <pre id="query-response-codemirror" class="brush: xml"></pre>
                </div>
                <div class="tab-pane" id="xquery-aceeditor-tab">
                  <input id="xquery-ace-editor-submit" type="button" value="Submit query" responsePreID="query-response-ace-editor" />
                  <br/>
                  <div id="ace-toolbar">
                    <div class="toolbar">
                      <select id="theme-select">
                        <optgroup label="Bright">
                          <option value="ace/theme/chrome">Chrome</option>
                          <option value="ace/theme/clouds">Clouds</option>
                          <option value="ace/theme/crimson_editor">Crimson Editor</option>
                          <option value="ace/theme/dawn">Dawn</option>
                          <option value="ace/theme/dreamweaver">Dreamweaver</option>
                          <option value="ace/theme/eclipse">Eclipse</option>
                          <option value="ace/theme/github">GitHub</option>
                          <option value="ace/theme/solarized_light">Solarized Light</option>
                          <option value="ace/theme/textmate" selected="selected">TextMate</option>
                          <option value="ace/theme/tomorrow">Tomorrow</option>
                          <option value="ace/theme/xcode">XCode</option>
                        </optgroup>
                        <optgroup label="Dark">
                          <option value="ace/theme/ambiance">Ambiance</option>
                          <option value="ace/theme/chaos">Chaos</option>
                          <option value="ace/theme/clouds_midnight">Clouds Midnight</option>
                          <option value="ace/theme/cobalt">Cobalt</option>
                          <option value="ace/theme/idle_fingers">idleFingers</option>
                          <option value="ace/theme/kr_theme">krTheme</option>
                          <option value="ace/theme/merbivore">Merbivore</option>
                          <option value="ace/theme/merbivore_soft">Merbivore Soft</option>
                          <option value="ace/theme/mono_industrial">Mono Industrial</option>
                          <option value="ace/theme/monokai">Monokai</option>
                          <option value="ace/theme/pastel_on_dark">Pastel on dark</option>
                          <option value="ace/theme/solarized_dark">Solarized Dark</option>
                          <option value="ace/theme/terminal">Terminal</option>
                          <option value="ace/theme/tomorrow_night">Tomorrow Night</option>
                          <option value="ace/theme/tomorrow_night_blue">Tomorrow Night Blue</option>
                          <option value="ace/theme/tomorrow_night_bright">Tomorrow Night Bright</option>
                          <option value="ace/theme/tomorrow_night_eighties">Tomorrow Night 80s</option>
                          <option value="ace/theme/twilight">Twilight</option>    
                          <option value="ace/theme/vibrant_ink">Vibrant Ink</option>
                        </optgroup>
                      </select>
                    </div>
                    <div class="toolbar">
                      <input type="checkbox" />Read Only
                    </div>
                    <div class="toolbar">
                      <select id="font-size-select">
                        <option value="Select Value">Font Size</option>
                        <option value="12">12px</option>
                        <option value="13">13px</option>
                        <option value="14">14px</option>
                        <option value="15">15px</option>
                      </select>
                    </div>
                    <div class="toolbar">
                      <input type="textfield"/>
                      <input id="ace-editor-search" type="button" value="Search"/>
                    </div>
                  </div>
                  <div id="ace-editor">
for $fruit in ('Apple', 'Pear', 'Peach')
  return switch ($fruit)
    case 'Apple' return 'red'
    case 'Pear'  return 'green'
    case 'Peach' return 'pink'
    default      return 'unknown'
                  </div>
                  <pre id="query-response-ace-editor" class="brush: xml"></pre>
                </div>
                <div class="tab-pane" id="cheat-sheet-tab">
                  <pre id="cheat-sheet" class="brush: xquery"></pre>
                </div>
              </div>
            </div>

            <div id="empty-content">Select a database to start with !</div>
          </div>
        </div>
      </div>
    </body>
  </html>
};

declare updating function page:update-info-index(){
  db:output("Updating info and facets files"),
  for $db in db:list() 
    return ( 
      file:write(concat('../webapp/basex-admin-console/xml/',concat($db,'_info.xml')),db:info($db)),
      file:write(concat('../webapp/basex-admin-console/xml/',concat($db,'_facets.xml')),index:facets($db))
    )
};

declare
      %restxq:path("/basex-admin-console/databases")
      %output:method("xml")
    function page:get-databases() {
      <databases>
        {
          for $db in db:list()
            return <database>{$db}</database> 
        }
      </databases>
};

declare
      %restxq:path("/basex-admin-console/databases/{$db-name}/xquery")
      %restxq:form-param("query","{$query}","")
      %output:method("xml")
    function page:xquery-databases($db-name, $query as xs:string) {
      try {
        xquery:eval($query)
      } catch * {
        'Error [' || $err:code || ']: ' || $err:description
      }
};

declare
        %restxq:GET
        %restxq:path("/basex-admin-console/read/{$db-name}")
        %output:method("xml")
      function page:get-database($db-name as xs:string) {
          db:open($db-name)
};

declare
        %restxq:POST
        %restxq:path("/basex-admin-console/update/{$db-name}")
        %restxq:form-param("xml","{$xml}", "<response>No param sent!</response>")
        %output:method("xml")
      updating function page:get-database($db-name as xs:string, $xml) {
          db:drop($db-name),
          db:create($db-name, $xml, "{$db-name}.xml"),
          page:update-info-index()
};
