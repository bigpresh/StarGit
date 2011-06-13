var githubNodesObj = {};
var githubEdgesObj = {};
var graphAttributes = {};

// Interface:
function init(){
	getGraphAttributes()
}

function newQuery(query){
  sigmaDOM = thisMovie("SiGMa");
  
  getGithubGraph(query);
}

function thisMovie(movieName) {
  if (navigator.appName.indexOf("Microsoft") != -1) {
    return window[movieName];
  } else {
    return document[movieName];
  }
}

function setComboBoxes(){
	var colorAtts = [];
	var sizeAtts = [];
	
	for(var att in graphAttributes){
		graphAttributes[att]["id"] = att;
		
		if(graphAttributes[att]["type"]=="Num"){
			sizeAtts.push(graphAttributes[att]);
			colorAtts.push(graphAttributes[att]);
		}else{
			colorAtts.push(graphAttributes[att]);
		}
	}
	
	var nodes_color = document.forms["node_properties"]["nodes_color"];
	var nodes_size = document.forms["node_properties"]["nodes_size"];
	
	while(nodes_color.options.length) nodes_color.options.remove(0);
	while(nodes_size.options.length) nodes_size.options.remove(0);
	
	var i;
	var optn;
	
	var l=colorAtts.length;
	for(i=0;i<l;i++){
		optn = document.createElement("OPTION");
		optn.text = colorAtts[i]["label"] ? colorAtts[i]["label"] : colorAtts[i]["id"];
		optn.value = colorAtts[i]["id"];
		
		nodes_color.options.add(optn);
	}
	
	l=sizeAtts.length;
	for(i=0;i<l;i++){
		optn = document.createElement("OPTION");
		optn.text = sizeAtts[i]["label"] ? sizeAtts[i]["label"] : sizeAtts[i]["id"];
		optn.value = sizeAtts[i]["id"];
		
		nodes_size.options.add(optn)
	}
}

// SiGMa interaction:
function toggleDisplayLabels(){
	if(sigmaDOM){
		if(sigmaDOM.getDisplayLabels()){
			sigmaDOM.setDisplayLabels(false);
		}else{
			sigmaDOM.setDisplayLabels(true);
		}	
	}
}

function toggleDisplayEdges(){
	if(sigmaDOM){
		if(sigmaDOM.getDisplayEdges()){
			sigmaDOM.setDisplayEdges(false);
		}else{
			sigmaDOM.setDisplayEdges(true);
		}	
	}
}

function toggleFishEye(){
	if(sigmaDOM){
		if(sigmaDOM.hasFishEye()){
			sigmaDOM.deactivateFishEye();
		}else{
			sigmaDOM.activateFishEye();
		}	
	}
}

function resetGraph(graph){
  recenterGraph();

  killForceAtlas();
  deleteGraph();
  updateGraph(graph);
  initForceAtlas();
  
  setColor(document.forms["node_properties"]["nodes_color"].value,graphAttributes);
  setSize(document.forms["node_properties"]["nodes_size"].value);
}

function onClickNodes(nodesArray){
  if(nodesArray.length){
    sigmaDOM = thisMovie("SiGMa");
    query = nodesArray[0];
    
    getGithubGraph(query);
    document.getElementById("query").value = query;
  }
}

function onOverNodes(nodesArray){
	for(var i=0;i<nodesArray.length;i++){
		console.debug("node: "+nodesArray[i]);
	}
}

// Github network:
function getGithubGraph(user){
  url = "/graph/local/"+user;
  
  $.ajax({
    url: url,
    dataType: 'json',
    success:
      function(json){
        resetGraph(json);
      }
  });
}

function getGraphAttributes(){
  url = "/graph/attributes";
  
  $.ajax({
    url: url,
    dataType: 'json',
    success:
      function(json){
        graphAttributes = (json && json["attributes"]) ? json["attributes"] : {};
        setComboBoxes();
      }
  });
}
