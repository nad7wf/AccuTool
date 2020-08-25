library(shiny)
library(shinyWidgets)
library(shinyBS)
library(shinycssloaders)
library(DT)
library(tidyverse)

setwd("/var/www/html/Dev/nad7wf/")

### Define UI logic.
ui <- fluidPage(
        bsCollapse(id = "panels", open = "Menu",
		   
		   ### Define objects for user input in the Menu tab.
                   bsCollapsePanel("Menu", 
                                   fluidRow(
                                       column(width = 4, 
                                              selectInput("chr",
                                                          label = "Chromosome",
                                                          choices = seq(1, 20),
                                                          selected = 1),
                                              numericRangeInput("pos_range", 
                                                                label = "Genomic interval:", 
                                                                value = c(0, 2000)),
                                              radioButtons("ref_pheno", 
                                                           label = "Reference Phenotype:", 
                                                           choices = c("WT", "MUT"), 
                                                           selected = "WT"),
                                              fileInput("pheno_file", 
                                                        label = "Choose Phenotype File (.csv):", 
                                                        accept = ".csv"),
					      a(href="Phenotype_template.csv", "Download Phenotype file template", download=NA, target="_blank"),
					      br(),
					      br(),
					      p("OR use a variant position (Tagging variant) as a synthetic phenotype:"),
					      selectInput("tagging_chr",
                                                          label = "Chromosome of tagging variant:",
                                                          choices = seq(1, 20),
                                                          selected = 1),
                                              numericInput("pheno_pos",
                                                        label = "Position of tagging variant:",
                                                        value = ""),
                                              fileInput("stats_file", 
                                                        label = "Choose GWAS Statistics File (.csv):", 
                                                        accept = ".csv"),
					      a(href="GWAS_statistics_template.csv", "Download GWAS statistics file template", download=NA, target="_blank"),
                                       ),
                                       column(width = 4, offset = 1,
                                              numericRangeInput("avg_acc_range", 
                                                                label = "Average accuracy filter:", 
                                                                value = c(0, 100)),
                                              numericRangeInput("acc_pess_range", 
                                                                label = "Combined accuracy pessimistic filter:", 
                                                                value = c(0, 100)),
                                              numericRangeInput("wt_acc_range", 
                                                                label = "WT accuracy filter:", 
                                                                value = c(0, 100)),
                                              numericRangeInput("mut_acc_range", 
                                                                label = "Mut accuracy filter:", 
                                                                value = c(0, 100)),
					      br(),
					      br(),
					      br(),
					      br(),
                                              radioButtons("only_p", 
                                                           label = "Return only positions with p-value:", 
                                                           choices = c("Yes", "No"), 
                                                           selected = "No"),
                                              radioButtons("only_mod",
                                                           label = "Return only amino acid-modifying variants:",
                                                           choices = c("Yes", "No"),
                                                           selected = "No"),
                                              radioButtons("only_snp50k",
								label = "Return only SNP50k positions:",
								choices = c("Yes", "No"),
								selected = "No")
                                       ),
                                       column(width = 2, style = 'padding-left: 60px; padding-top: 26px;',
                                              actionButton("calc_acc", 
                                                           label = "Calculate Accuracy"),
                                              hr(),
                                              downloadButton("download",
                                                             label = "Download Results")
                                       )
                                   )
                   ),

		   ### Render table of results.
                   bsCollapsePanel("Results",
                                   fluidRow(
                                       column(width = 12,
                                             DTOutput("data.out") %>%
                                                  withSpinner(color = "#595959")
                                       )
                                   )
                   )
        )
)

### Define server logic.
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
                 message = "Start of genomic interval must be less than or equal to end."),
            
            need(try(input$avg_acc_range[1] <= input$avg_acc_range[2]),
                 message = "Average accuracy filter start range must be less than or equal to end."),

            need(try(input$acc_pess_range[1] <= input$acc_pess_range[2]),
                 message = "Combined accuracy pessimistic filter start range must be less than or equal to end."),

            need(try(input$wt_acc_range[1] <= input$wt_acc_range[2]),
                 message = "WT accuracy filter start range must be less than or equal to end."),

            need(try(input$mut_acc_range[1] <= input$mut_acc_range[2]),
                 message = "Mut accuracy filter start range must be less than or equal to end.")
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
                            input$acc_pess_range[1],
                            input$acc_pess_range[2],
                            input$wt_acc_range[1],
                            input$wt_acc_range[2],
                            input$mut_acc_range[1],
                            input$mut_acc_range[2],
                            input$only_p,
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
                 col_types = cols(Chr = "i",
				  Pos = "i",
				  `Avg_Accuracy (%)` = "d",
                                  `Comb_Accu_Pess (%)` = "d",
				  `p.value` = "d",
				  SoySNP50k_ID = "c",
				  Gene = "c",
				  Effect = "c",
				  `WT_Accu (%)` = "d",
				  Num_of_WT_Lines = "i",
				  `Missing_Genotype_WT (%)` = "d",
				  `MUT_Accu (%)` = "d",
				  Num_of_MUT_Lines = "i",
				  `Missing_Genotype_MUT (%)` = "d",
				  `Missing_Phenotype (%)` = "d",
				  Multiple_ALT = "c",
				  REF = "c",
				  ALT = "c")
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
	    mutate(results(),
		   Gene = sub("<.*>(Glyma\\.\\d+g\\d+)<.*>", "\\1", Gene)) %>%
            	   write_tsv(file,
                      	     col_names = TRUE)
        }
    )
}

# Run the application 
shinyApp(ui, server)
