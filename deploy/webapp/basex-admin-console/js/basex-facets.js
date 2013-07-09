var codeMirror;
var codeMirrorUIEditor;
var aceEditor;

$(document).ready(function(){
  $('.elementsOnly').click(showElementsOnly);
  $('.elementsAndAttributes').click(showElementsAndAttributes);
  $('.allNodes').click(showAll);
  $('#toggleSidebar').click(function(){
    $('#side-bar-contents').toggle();

    $("#toggleSidebar").toggleClass('more');

    $('#side-bar').toggleClass("span3");
    $('#side-bar').toggleClass("hidden-side-bar");
    $('#side-bar').toggleClass("span");

    $('#content').toggleClass("span9");
    $('#content').toggleClass("span11");

    $('#side-bar-control').toggleClass("hidden-side-bar-control");
    updateSideBarAndContentWidth($("#side-bar").attr("style")=="display: block");
  });

  $("input:radio[name='dbOptionsRadios']").change(function () {
    var dbName = $(this).attr("db-name");
    if ($(this).attr("value") == "facets") {
      showGivenChildAndHideOthers("content", "chart");

      // Show the facets-controls-div
      $(".facets-controls-div").show();

      // show the bezier-tree by default
      $("#bezier-tree-tab").tab('show');

      var dbFacetFile = "/basex-admin-console/xml/" + dbName + "_facets.xml";
      renderBezierTree(dbFacetFile);
      // Set "Elements only radio button" by default
      $("input:radio[class='elementsAndAttributes'][db-name="+dbName+"]").prop("checked",true);
    }else if($(this).attr("value") == "info") {
      showGivenChildAndHideOthers("content", "info");

      // Hide the facets-controls-div
      $(".facets-controls-div").hide();

      var dbInfoFile = "/basex-admin-console/xml/" + dbName + "_info.xml";
      renderInfoFile(dbInfoFile);
      // Remove selections of "facets-controls"
      $("input:radio[name='facets-controls']").prop("checked",false)

      // Hide the topScroll bar, has no meaning when showing info
      $("#topScroll").hide();
    }else if($(this).attr("value") == "query"){
      // Hide the facets-controls-div
      $(".facets-controls-div").hide();
      // Show query div
      showGivenChildAndHideOthers("content", "query");
    };
  });

  updateSideBarAndContentWidth(true);

  // Window resize issue
  $(window).resize(function() {
    updateSideBarAndContentWidth($("#side-bar").attr("style")=="display: block");
  });

  topScroll();

  // Show default div only "empty-content"
  showGivenChildAndHideOthers("content", "empty-content");
  // Hide the facets-controls-div by default
  $(".facets-controls-div").hide();

  // Change in accordions
  $('#dbs-accordions').on('shown', function () {
    var dbFacetFile = "/basex-admin-console/xml/" + $(".in.collapse").attr("id") + "_facets.xml";
    renderBezierTree(dbFacetFile);
    showGivenChildAndHideOthers("content", "chart");
    // show the bezier-tree by default
    $("#bezier-tree-tab").tab('show')
    $(".facets-controls-div").show();
  });

  $('#dbs-accordions').on('hidden', function () {
    if($(".in.collapse").attr("id")==undefined){
      showGivenChildAndHideOthers("content", "empty-content");
      // Hide the topScroll bar, has no meaning when showing nothing
      $("#topScroll").hide();
    };
  });

  // First set up some variables
  var textarea = document.getElementById('xquery-textarea');
  var uiOptions = { path : 'xquery/', searchMode : 'popup',
                    imagePath : "/basex-admin-console/3rd-party/codemirror-ui/images/silk" }
  var codeMirrorOptions = { mode: "xquery", lineNumbers: true}

  // Then create the editor
  codeMirrorUIEditor = new CodeMirrorUI(textarea,uiOptions,codeMirrorOptions);

  // cheatSheetContent is set in external js file
  $("#cheat-sheet").text(cheatSheetContent);
  // SyntaxHighlighter
  SyntaxHighlighter.highlight("#cheat-sheet");

  // Hide the query-response-codemirror div
  $("#query-response-codemirror, #query-response-ace-editor").hide();

  // Ace Editor
  aceEditor = ace.edit("ace-editor");
  aceEditor.getSession().setMode("ace/mode/xquery");

  // Setting toolbar actions
  $("#xquery-code-mirror-submit, #xquery-ace-editor-submit").click(function (){
    submitQuery(this);
  });

  $("#theme-select").click(function (){
    aceToolbarTheme(this);
  });

  $("#font-size-select").click(function (){
    aceToolbarFontSize(this);
  });

  $(".toolbar input[type='checkbox']").change(function () {
    aceToolbarReadOnly();
  });

  $("#ace-editor-search").click(function (){
    var searchWord = $(this).prev().val();
    aceToolbarFind(searchWord);
  });

  $("#ace-editor-search").prev().keyup(function(e){
    if(e.keyCode==13){
      var searchWord = $(this).val();
      aceToolbarFind(searchWord);
    }
  });
});

// Scrollbar on top scroll with the treeChart div
function topScroll () {
  $("#topScroll").scroll(function(){
      $("#treeChart")
          .scrollLeft($("#topScroll").scrollLeft());
  });
  $("#treeChart").scroll(function(){
      $("#topScroll")
          .scrollLeft($("#treeChart").scrollLeft());
  });
}

function updateSideBarAndContentWidth (isShownSideBar) {
  var facetsOptionsMargin = 30; // + marigin inside the sidebar
  var sideBarMinWdth = 240+facetsOptionsMargin; 
  var sideBarDivWidth = 0;
  if (isShownSideBar) {
    // Dynamically setting width of side-bar and content divs
    var longestDbNameLength = 0;
    $(".accordion-toggle").each(function () {
      var itemWidth = this.text.getWidth({'fontSize':'12px'});
      if ( itemWidth > longestDbNameLength) {
        longestDbNameLength = itemWidth;
      };
    })
    sideBarDivWidth = longestDbNameLength + 3*facetsOptionsMargin; // 9px per character
    sideBarDivWidth = (sideBarDivWidth<sideBarMinWdth) ? sideBarMinWdth : sideBarDivWidth;
    $("#side-bar").width(sideBarDivWidth); 
    $("#dbs-accordions").width(sideBarDivWidth-facetsOptionsMargin); // - marigin inside the sidebar
  }else{
    sideBarDivWidth = $("#side-bar").width();
  };
  // Set content div width
  var rightPaddingOfContainerFluid = $(".container-fluid").css("padding-right").replace(/[^-\d\.]/g, '');
  var rightPaddingOfBody = $("body").css("padding-right").replace(/[^-\d\.]/g, '');
  var contentDivWidth = $(window).width() - sideBarDivWidth - 2*rightPaddingOfContainerFluid - 2*rightPaddingOfBody - 35;
  $("#content").width(contentDivWidth);
}

function showGivenChildAndHideOthers (parentDiv, divToShow) {
  $("#"+parentDiv+">div").hide();
  $("#"+divToShow).show();
}

function submitQuery (element) {
  var responsePreID = $(element).attr("responsePreID");
  var query;
  if (responsePreID=="query-response-codemirror") {
    query = codeMirrorUIEditor.mirror.getValue();
  } else{
    query = aceEditor.getValue();
  };
  var dbName = $("input:radio[name='dbOptionsRadios']").attr("db-name");
  // console.log(query);
  $("#"+responsePreID).replaceWith("<pre id=\""+responsePreID+"\" class=\"brush: xml\"></pre>");
  $.ajax({               
            type: 'POST',
            url: "/restxq/basex-admin-console/databases/"+dbName+"/xquery",
            dataType: 'text',
            data: {'query': query},
            success: function(data) {
              // console.log(data);
              $("#"+responsePreID).html(data.replace(/</g, '&lt;').replace(/>/g, '&gt;'));

              $("#"+responsePreID).show();
              // SyntaxHighlighter
              SyntaxHighlighter.highlight();

              if (data.indexOf("Error") == 0) {
                $("#"+responsePreID+" .plain").attr('style', 'color: red !important;');
              }
            },
            error: function (jqXHR, textStatus, errorThrown) {
              $("#"+responsePreID).hide();
              // alert(errorThrown);
            }
          });
}

function aceToolbarReadOnly () {
  if (aceEditor.getReadOnly()) {
    aceEditor.setReadOnly(false);
  } else{
    aceEditor.setReadOnly(true);
  };
}

function aceToolbarFontSize (element) {
  var size = parseInt($("#font-size-select").val());
  if (size){
    aceEditor.setFontSize(size);
  }
}

function aceToolbarTheme (element) {
  var theme = $("#theme-select").val();
  aceEditor.setTheme(theme);
}

function aceToolbarFind (token) {
  aceEditor.find(token);
}