var stargit=(function(){
	var flash;
	var githubNodesObj = {};
	var githubEdgesObj = {};
	var graphAttributes = {};
	
	function setFlash(){
		if (navigator.appName.indexOf("Microsoft") != -1) {
			flash = window["SiGMa"];
		} else {
			flash = document["SiGMa"];
		}
		
		if(!flash){
			return false;
		}else{
			return true;
		}
	}
	
	function setLegend(attName,attribute){
	  // First, let's remove all "legend_element" elements:
	  $("#legend>*").remove();
		
	  // Then, let's add the new legend elements:
	  var legTitle = document.createElement("div");
	  legTitle.id = "legend_title";
		
	  $("#legend").append(legTitle);
	  $("#legend_title").append("Nodes color: ");
		
	  var fieldB = document.createElement("strong");
	  fieldB.style.fontSize = "10px";
	  fieldB.innerHTML = (attribute["label"]?attribute["label"]:attName);
	  $("#legend_title").append(fieldB);
		
	  var legElements = document.createElement("div");
	  legElements.id = "legend_elements";
		
	  $("#legend").append(legElements);
		
	  if(attribute["type"]=="Num"){
	    var grad = document.createElement("div");
	    grad.style.backgroundImage = 
	      "-webkit-gradient("+
	      "    linear,"+
	      "    left top,"+
	      "    right top,"+
	      "    color-stop(0, "+attribute["colorMax"].replace("0x","#")+"),"+
	      "    color-stop(1, "+attribute["colorMin"].replace("0x","#")+"))";
    	    
    	    grad.style.backgroundImage = 
	      "-moz-linear-gradient("+
	      "    left center,"+
	      "    "+attribute["colorMax"].replace("0x","#")+" 0%,"+
	      "    "+attribute["colorMin"].replace("0x","#")+" 100%)";
	    
	    $("#legend_elements").append("<br/>");
	    
	    grad.style.height = "20px";
	    grad.style.width = "80%";
	    grad.style.marginLeft = "10%";
    	
	    $("#legend_elements").append(grad);
			
	    var lowest = document.createElement("div");
	    lowest.style.paddingTop = "5px";
	    lowest.style.paddingLeft = "5px";
	    lowest.style.float = "left";
	    lowest.style.styleFloat = "left";
	    lowest.style.cssFloat = "left";
	    lowest.style.display = "inline";
	    lowest.innerHTML = "(lowest values)";
	    $("#legend_elements").append(lowest);

	    var highest = document.createElement("div");
	    highest.style.paddingTop = "5px";
	    highest.style.paddingRight = "5px";
	    highest.style.float = "right";
	    highest.style.styleFloat = "right";
	    highest.style.cssFloat = "right";
	    highest.style.display = "inline";
	    highest.innerHTML = "(highest values)";
	    $("#legend_elements").append(highest);
			
	  }else if(attribute["type"]=="Str"){
	    for(var val in attribute["values"]){

              var divname = val.replace(" ", "_");
              var legend  = document.createElement("div");
              legend.id = "value_"+divname;
              legend.style.float="left";
              legend.style.width = "110px";
              $("#legend_elements").append(legend);
				
              var background = document.createElement("div");
              background.style.width = "13px";
              background.style.height = "13px";
              background.style.marginLeft = "12px";
              background.style.marginTop = "12px";
              background.style.float = "left";
              background.style.styleFloat = "left";
              background.style.cssFloat = "left";
              background.style.border = "1px solid black";
              background.style.backgroundColor = attribute["values"][val].replace("0x","#");
              $("#value_"+divname).append(background);

              var texte = document.createElement("div");
              texte.innerHTML = val + "<br />";
              texte.style.paddingLeft = "3px";
              texte.style.marginTop = "12px";
              texte.style.float = "left";
              texte.style.styleFloat = "left";
              texte.style.cssFloat = "left";
              $("#value_"+divname).append(texte);
            }
	  }
	}
	
	// This function refreshes the graph from the login of
	// a user:
	function getGithubGraph(user){
          $("#user").hide();
          $("#error").hide();
	  url = "/graph/local/"+user;
	  $.ajax({
	    url: url,
	    dataType: 'json',
            error:function(){
              $("#user").hide();
              $("#error").show();
              $("#error_reason").text("Can't find graph for user " + user);
            },
	    success:
	    function(json){
              console.log(json);
              if (json.nodes.length == 0){
                $("#error").show();
                $("#error_reason").text("This user has not received any contributions");
              }
              $("#info_graph_desc").text("The graph for " + user + " contains " + json.nodes.length + " nodes and " + json.edges.length + " edges");
	      resetGraph(json);
	      if(document.getElementById("query_input").value)
                document.getElementById("query_input").value = user;
	    }
	  });
	}

	function resetGraph(graph){
		if(!setFlash()){
			return;
		}
		
	  flash.resetGraphPosition();
	
	  flash.killForceAtlas();
	  flash.deleteGraph();
	  flash.updateGraph(graph);
	  flash.initForceAtlas();
	  
	  if(document.getElementById("query_color").value) flash.setColor(document.getElementById("query_color").value,graphAttributes);
	  if(document.getElementById("query_size").value) flash.setSize(document.getElementById("query_size").value);
	}

	// This function updates the comboboxes:
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
		
		var nodes_color = document.getElementById("query_color");
		var nodes_size = document.getElementById("query_size");
		
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
		
		if(graphAttributes){
			setLegend(colorAtts[0]["label"],colorAtts[0]);
		}
	}
	
	// PUBLIC FUNCTIONS:
	return {
		loadUser: function(name){
			getGithubGraph(name);
		},
		
		setSize: function(e){
			if(!setFlash()) return;
			flash.setSize(e.target.value);
		},
		
		setColor: function(e){
			if(!setFlash()) return;
			
			setLegend(e.target.value,graphAttributes[e.target.value]);
			
			flash.setColor(e.target.value,graphAttributes);
		},
		
		toggleEdges: function(){
			if(!setFlash()) return;
			var areEdgesDisplayed = flash.getDisplayEdges();
			flash.setDisplayEdges(!areEdgesDisplayed);
			return !areEdgesDisplayed;
		},
		
		toggleLabels: function(){
			if(!setFlash()) return;
			var areLabelsDisplayed = flash.getDisplayLabels();
			flash.setDisplayLabels(!areLabelsDisplayed);
			return !areLabelsDisplayed;
		},
		
		toggleFishEye: function(){
			if(!setFlash()) return;
			var isFishEye = flash.hasFishEye();
			if(isFishEye){
				flash.deactivateFishEye();
			}else{
				flash.activateFishEye();
			}
			return !isFishEye;
		},
		
		getGraphAttributes: function(){
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
		},

		onClickNodes: function(nodesArray){
		  if(nodesArray.length){
		    query = nodesArray[0];
		    
		    getGithubGraph(query);
		    document.getElementById("query_input").value = query;
			}
		},
		
		onOverNodes: function(nodesArray){
                  if (nodesArray[0]){
		    var url = "/profile/" + nodesArray[0];
		    $.ajax({
		      url: url,
		      dataType: 'json',
		      success:
		      function(json){
                        $("#error").hide();
                        $("#user").show();
                        var gravatar = "http://www.gravatar.com/avatar/" + json.gravatar;
                        $("#gravatared").attr("src", gravatar);
                        $("#gravatared").show();
                        $("#user_name").text(json.name);
                        $("#user_website").text(json.website);                        
                        $("#user_indegree").text(json.indegree);                        
                        $("#user_country").text(json.country);                        
                        $("#user_language").text(json.language);                        
		      }
		    });
                  }
		}
	};
})();
