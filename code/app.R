library(shiny)
library(shinyWidgets)
library(shinyBS)
library(shinycssloaders)
library(DT)
library(tidyverse)

setwd("/var/www/html/Dev/nad7wf/")


ui <- fluidPage(
        
        bsCollapse(id = "panels", open = "Menu",
                   
                   bsCollapsePanel("Menu", 
                                   
                                   fluidRow(
                                       
                                       column(width = 3, style = 'padding: 10px',
                                              
                                              selectInput("chr",
                                                          label = "Chromosome",
                                                          choices = seq(1, 20),
                                                          selected = 1),
                                              numericRangeInput("pos_range", 
                                                                label = "Chromosome range:", 
                                                                value = c(0, 2000)),
                                              radioButtons("ref_pheno", 
                                                           label = "Reference Phenotype:", 
                                                           choices = c("WT", "Mut"), 
                                                           selected = "WT"),
                                              fileInput("pheno_file", 
                                                        label = "Choose Phenotype File (.csv):", 
                                                        accept = ".csv"),
					      p("OR use a tagging variant as a phenotype:"),
					      selectInput("tagging_chr",
                                                          label = "Chromosome of tagging variant:",
                                                          choices = seq(1, 20),
                                                          selected = 1),
                                              numericInput("pheno_pos",
                                                        label = "Position of tagging variant:",
                                                        value = ""),
                                              fileInput("stats_file", 
                                                        label = "Choose GWAS Statistics File (.csv):", 
                                                        accept = ".csv")
                                              
                                       ),
                                       
                                       column(width = 4, style = 'padding: 0px',
                                              
                                              numericRangeInput("avg_acc_range", 
                                                                label = "Average accuracy filter:", 
                                                                value = c(0, 100)),
                                              numericRangeInput("avg_acc_pess_range", 
                                                                label = "Average accuracy filter:", 
                                                                value = c(0, 100)),
                                              numericRangeInput("acc_range", 
                                                                label = "Combined accuracy filter:", 
                                                                value = c(0, 100)),
                                              numericRangeInput("acc_pess_range", 
                                                                label = "Combined accuracy pessimistic filter:", 
                                                                value = c(0, 100)),
                                              numericRangeInput("wt_acc_range", 
                                                                label = "WT accuracy filter:", 
                                                                value = c(0, 100)),
                                              numericRangeInput("wt_acc_pess_range", 
                                                                label = "WT accuracy pessimistic filter:", 
                                                                value = c(0, 100)),
                                              numericRangeInput("mut_acc_range", 
                                                                label = "Mut accuracy filter:", 
                                                                value = c(0, 100)),
                                              numericRangeInput("mut_acc_pess_range", 
                                                                label = "Mut accuracy pessimistic filter:", 
                                                                value = c(0, 100))
                                              
                                       ),
                                       
                                       column(width = 3, style = 'padding: 0px',
                                              
                                              numericRangeInput("p_range", 
                                                                label = "P-value filter:", 
                                                                value = c(0, 1)),
                                              radioButtons("only_p", 
                                                           label = "Show only positions with p-value:", 
                                                           choices = c("Yes", "No"), 
                                                           selected = "No"),
                                              radioButtons("only_mod",
                                                           label = "Show only 'modifying' variants:",
                                                           choices = c("Yes", "No"),
                                                           selected = "No"),
                                              radioButtons("only_snp50k",
								label = "Show only SNP50k positions:",
								choices = c("Yes", "No"),
								selected = "No")
                                              
                                       ),
                                       
                                       column(width = 2, style = 'padding: 0px',
                                              
                                              actionButton("calc_acc", 
                                                           label = "Calculate Accuracy"),
                                              hr(),
                                              downloadButton("download",
                                                             label = "Download Results")
                                              
                                       )
                                       
                                   )
                                   
                   ),
                   
                   bsCollapsePanel("Results",
                                   
                                   fluidRow(
                                       
                                       column(width = 12,
                                              
                                             DTOutput("data.out") %>%
                                                  withSpinner(color = "#A9A9A9")
                                              
                                       )
                                       
                                   )
                                   
                   )
                   
        )

)



server <- function(input, output, session) {
    
    ### Increase allowable input file size.
    options(shiny.maxRequestSize=1000*1024^2)
    
    
    ### Automatically switch to the results panel when the user clicks 'Calculate Accuracy' button.
    observeEvent(input$calc_acc, {
        
        updateCollapse(session, "panels", open = "Results")
        
    })
    
    
    ### Run accuracy calculation when user clicks 'Calculate Accuracy' button.
    results <- eventReactive(input$calc_acc, {
        
        ### Validate user input values.
        shiny::validate(
            
            need(try((is.null(input$pheno_file) | is.na(input$pheno_pos))),
                 message = "You must pick either a phenotype file or a tagging variant. Not both."),
            
            need(try((!is.null(input$pheno_file) | !is.na(input$pheno_pos))),
                 message = "You must provide either a phenotype file or a tagging variant."),
            
            need(try(input$pos_range[1] < input$pos_range[2]),
                 message = "Beginning chromosome range must be smaller than end chromosome range."),
            
            need(try(input$acc_range[1] <= input$acc_range[2]),
                 message = "Combined accuracy filter start range must be smaller than end range."),

            need(try(input$acc_pess_range[1] <= input$acc_pess_range[2]),
                 message = "Combined accuracy pessimistic filter start range must be smaller than end range."),

            need(try(input$wt_acc_range[1] <= input$wt_acc_range[2]),
                 message = "WT accuracy filter start range must be smaller than end range."),

            need(try(input$wt_acc_pess_range[1] <= input$wt_acc_pess_range[2]),
                 message = "WT accuracy pessimistic filter start range must be smaller than end range."),

            need(try(input$mut_acc_range[1] <= input$mut_acc_range[2]),
                 message = "Mut accuracy filter start range must be smaller than end range."),

            need(try(input$mut_acc_pess_range[1] <= input$mut_acc_pess_range[2]),
                 message = "Mut accuracy pessimistic filter start range must be smaller than end range."),

            need(try(input$p_range[1] <= input$p_range[2]),
                 message = "P-value filter start range must be smaller than end range.")

        )
        
        ### If chr is single digit (1-9) add prepending zero to chr number.
	chr <- input$chr

	if (nchar(chr) == 1) {

		chr <- paste(c("0", chr), collapse = "")

	}
	
	tagging_chr <- input$tagging_chr

	if (nchar(tagging_chr) == 1) {

		tagging_chr <- paste(c("0", tagging_chr), collapse = "")

	}

        ### Create genotype filename from chromosome number.
        geno_file <- paste(c("./AccuTool_Soy2020_Chr", chr, ".vcf.gz"), collapse = "")
        pheno_geno_file <- paste(c("./AccuTool_Soy2020_Chr", tagging_chr, ".vcf.gz"), collapse = "")
        
        ### Assign either phenotype file or genotype position to "pheno".
        if (!is.null(input$pheno_file)) {
            
        	pheno <- input$pheno_file[['datapath']]
                
        } else if (input$pheno_pos != "") {

        	pheno <- as.numeric(input$pheno_pos)

        }

	### Capture temp stats filename.
	if (!is.null(input$stats_file)) {

		stats_file <- input$stats_file[['datapath']]

	} else {

		stats_file <- NULL

	}

        ### Convert reference phenotype from 'WT' or 'Mut' to 1 or 2.
        numeric_ref_pheno <- if_else(input$ref_pheno == 'WT', 1, 2)
        
        
        ### Create vector of parameters from user inputs to pass to Perl script.
        parameters <- paste(geno_file,
			    pheno_geno_file,
                            pheno,
                            input$pos_range[1],
                            input$pos_range[2],
                            numeric_ref_pheno,
			    input$avg_acc_range[1],
			    input$avg_acc_range[2],
			    input$avg_acc_pess_range[1],
			    input$avg_acc_pess_range[2],
                            input$acc_range[1],
                            input$acc_range[2],
                            input$acc_pess_range[1],
                            input$acc_pess_range[2],
                            input$wt_acc_range[1],
                            input$wt_acc_range[2],
                            input$wt_acc_pess_range[1],
                            input$wt_acc_pess_range[2],
                            input$mut_acc_range[1],
                            input$mut_acc_range[2],
                            input$mut_acc_pess_range[1],
                            input$mut_acc_pess_range[2],
                            input$only_p,
                            input$p_range[1],
                            input$p_range[2],
                            input$only_mod,
			    input$only_snp50k,
			    stats_file,
                            collapse = " ")
        
        
        ### Generate command to execute Perl script.
        cmd <- paste("perl calc_accuracy.pl", parameters, collapse = " ")
        
        ### Execute Perl script and read output into tibble.
        read_tsv(pipe(cmd),
                 trim_ws = TRUE,
                 na = "NA",
                 col_names = TRUE,
                 col_types = cols(Acc_Combined = "i",
                                  Acc_Combined_Pessimistic = "i",
                                  Acc_WT = "i",
                                  Acc_WT_Pessimistic = "i",
                                  Missing_Genotype_WT = "i",
                                  WT_Lines = "i",
                                  Acc_Mut = "i",
                                  Acc_Mut_Pessimistic = "i",
                                  Missing_Genotype_Mut = "i",
                                  Mut_Lines = "i",
                                  P.Val = "d",
                                  Ref = "c", 
                                  Alt = "c")
                 )

        
    })
    
    
    ### Render output of Perl script to DataTable.
    output$data.out <- renderDT(results(),
                                rownames = FALSE,
				escape = FALSE,
                                options = list(scrollX = TRUE,
                                               scrollY = "80vh",
                                               paging = FALSE,
                                               dom = 'tr',
                                               processing = TRUE,
                                               search.regex = TRUE,
                                               type = "string")
                                )
    
    
    ### Function to download results.
    output$download <- downloadHandler(

        ### Create default filename.
        filename = function() {

            paste("results-", Sys.Date(), ".txt", sep = "")
            
        },

        ### Write results to file.
        content = function(file) {

            write_tsv(results(), 
                      file,
                      col_names = TRUE)

        }

    )
    
}

# Run the application 
shinyApp(ui, server)
