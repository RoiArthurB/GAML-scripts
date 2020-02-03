/***
* Name: listNoIndex
* Author: roiarthurb
* Description: This small GAML script aimed to list unused pages from the gama-platform/gama.wiki repository
* To do so it :
* - 1 Scrap every markdown files name from gama-platform/gama.wiki
* - 2 Turn the sidebar json into a list
* - 3 List&return all un-matching elements
* Tags: Tag1, Tag2, TagN
***/

model listNoIndex

global {
	
	/* VAR */
	string pathToWiki <- "/home/roiarthurb/Documents/GAMA/gama.wiki" parameter:true;
	string pathToSidebarJson <- "/home/roiarthurb/Documents/GAMA/gama-platform.github.io/website/sidebars.json" parameter:true;
	bool verbose <- false parameter:true;
	/* === */
	
	/* INIT */
	init{		
		/* GET md files */
		list<string> mdFiles <- getFileInFolder(pathToWiki) 
			where (each at (length(each)-1) = "d" and each at (length(each)-2) = "m" and each at (length(each)-3) = "." ); // Take only *.md
		
		if verbose { write (string(length(mdFiles)) + " MarkDown files founded"); }
		/* === */
		
		/* GET sidebard pages */
		list<string> sidebarContent <- json2list( json_file(pathToSidebarJson).contents );
		if verbose { write "Sidebar list : "; write sidebarContent; }
		/* === */
		
		/* DIFF non-used md */
		list<string> nonUsedPages;
		loop file over: mdFiles {
			if !(sidebarContent contains replace_regex(replace_regex(file, ".md", ""), "-", "")) {
				add file to: nonUsedPages;
			}
		}

		write "Total of non-used pages present in the wiki repository : " + string(length(nonUsedPages));
		write nonUsedPages;
		/* === */
	}
	
	/*
	 * Get non-hidden files name in given folder and sub-folders
	 * 
	 * @param  folderPath Full path of the folder you want to extract file list from
	 * @return List of every files name in (sub-)folder
	 */
	list<string> getFileInFolder(string folderPath){
		if verbose { write("Starting in : " + folderPath); }
		
		list<string> files <- list<string>(folder(folderPath).contents) where (each at 0 != "."); // w/o .git, .project, etc
		list<string> folderInFiles;
		
		// Check if file or folder
		loop file over: files {
			//write file;
			if !file_exists(folderPath + "/" + file){ // It's a folder
				if verbose { write("Adding "+ folderPath + "/" + file); }
				add file to: folderInFiles;
			}
		}
		
		// Recursive
		loop folder over: folderInFiles {
			// Remove bad index
			remove folder from: files;
			
			// Get files in folder
			list<string> subFolder <- getFileInFolder(folderPath+"/"+folder);
			// and add them to current files list
			loop file over: subFolder {
				add file to: files;
			}
		}
		
		return files;
	}

	
	/*
	 * Turn a multi-dimensional json to an array
	 * /!\ Will lost mapping data /!\
	 * 
	 * @param  `json_file( ).contents`
	 * @return List of content from the JSON
	 */
	list<string> json2list(container jsonContent){
		list<string> jsonList;
		
		// Loop over map or list
		loop content over: jsonContent{
			// Add to final list if string
			if type_of(content) = string {
				add content to: jsonList;
			} else {	// Else recursive
				list<string> subList <- json2list(content);
				loop element over: subList {
					add element to: jsonList;
				}
			}
		}
		
		return jsonList;
	}
}


experiment listNoIndex type: gui {}
