#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(RPostgres)
library(DT)

db_name='chembl_25'
user_name = 'postgres'
host='192.168.1.180'
port=5432

conn = dbConnect(drv=RPostgres::Postgres(),
                 dbname=db_name,
                 user=user_name,
                 host=host,
                 port=port)

q_organism_thresholds = "
                      select tax_id, num_clusters, organism, threshold
                      from hmmer_threshold
                      order by organism"

q_scores='select score
          from hmmer_statistics
          where tax_id='

q_drugs_select="
select avg(score) as score
  , td.tax_id as original_tax_id
  , td.organism as orig_organism
  , md.pref_name
  , md.chembl_id
  , dm.mechanism_of_action
  , md.max_phase
  , md.first_approval 
from hmmer_statistics h
    join target_dictionary td
    on h.target = td.chembl_id
    join drug_mechanism dm
    ON dm.tid = td.tid
    join molecule_dictionary md
    ON dm.molregno = md.molregno "

q_drugs_group_by = " group by td.tax_id
    , td.organism
    , md.pref_name
    , md.chembl_id
    , dm.mechanism_of_action
    , md.max_phase
    , md.first_approval "

q_drugs_order_by =" order by pref_name "
q_drugs_orfs = "
select avg(score) as score
      , td.tax_id as original_tax_id
      , td.organism as orig_organism
      , md.pref_name
      , md.chembl_id
      , h.orf
from hmmer_statistics h
      join target_dictionary td
      on h.target = td.chembl_id
      join drug_mechanism dm
      ON dm.tid = td.tid
      join molecule_dictionary md
      ON dm.molregno = md.molregno
      JOIN compound_records cr
      ON md.molregno = cr.molregno
      "
q_drugs_orfs_group_by = "
group by  td.tax_id
        , td.organism
        , md.pref_name
        , md.chembl_id
        , h.orf "

get_kmeans_threshold<-function(conn, tax_id, clusters=2){
  q_tax_org = paste0('SELECT distinct organism ',
                     'FROM hmmer_statistics ',
                     'where tax_id=',
                     tax_id)
  q_org_score = paste0(
    'select distinct score, orf, target
     from hmmer_statistics h
              join target_dictionary td 
               on h.target = td.chembl_id 
               join drug_mechanism dm 
               ON dm.tid = td.tid 
               join molecule_dictionary md 
              ON dm.molregno = md.molregno 
          WHERE h.tax_id ='
    , tax_id
  )
  
  org=dbGetQuery(conn,q_tax_org)
  org_score=dbGetQuery(conn, q_org_score)
  organism=org$organism[1]
  attach(org_score)
  #  kmo=kmeans(score,2)
  kmo=kmeans(score,clusters)
  
  thresh = min(score[ # lowest score
    kmo$cluster==which(kmo$centers==max(kmo$centers)) # in highest cluster
    ])  
  plot(score,col=kmo$cluster, main=paste('kmeans for ',organism, ', threshold=',thresh)) 
  for (cluster in 1:kmo$iter){
    thresh=min(scores$score[kmo$cluster==cluster])
    abline(h=thresh,col='purple', lwd=2)
  }
  
  detach()
  return(thresh)
}

organisms=dbGetQuery(conn, q_organism_thresholds)

organism_choices=list()
for ( tax_id in organisms$tax_id){
  organism_choices[[organisms$organism[organisms$tax_id==tax_id]]]=tax_id
}

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Paralog targets and drugs"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        selectInput("organism", label = h3("Select organism"), 
                    choices = organism_choices),
         tax_id = "organism.selected",
         sliderInput("bins",
                     "Number of bins:",
                     min = 1,
                     max = 50,
                     value = 30),
         sliderInput("clusters",
                     "number of clusters",
                     min = 2,
                     max = 5,
                     value = organisms$num_clusters[organisms$tax_id == tax_id]),
        radioButtons('thresholdChoices','Threshold choices:', choices=20,inline = TRUE)
        ),

      # Show a plot of the generated distribution
      mainPanel(
        tabsetPanel(type = "tabs",
                    tabPanel("plots",
                             plotOutput("distPlot"),
                             plotOutput("kmeansPlot")
                    ),
                    tabPanel('drugs',
                             textOutput('queryThreshold'),
                             hr(),
                             dataTableOutput("drugsTable"),
                             downloadButton('downloadDrugs', 'Download drugs')),
                    tabPanel('drugs_orfs',
                             textOutput('orfQueryThreshold'),
                             hr(),
                             dataTableOutput("drugsOrfsTable"),
                             downloadButton("downloadDrugsOrfs", "Download DrugsOrfs"))
        )
       )
   )
)

server <- function(input, output, session) {
   r_tax_id=reactive(input$organism)
   r_score=reactive(dbGetQuery(conn,paste0(q_scores,r_tax_id()))[,1])
   r_drugs_table=reactive({
     thresh=as.integer(input$thresholdChoices)
     q_drugs_where = paste0("WHERE h.tax_id = ",r_tax_id(), ' and score >= ', thresh)
     q_drugs=paste0(q_drugs_select,q_drugs_where, q_drugs_group_by, q_drugs_order_by)
     drugs=dbGetQuery(conn, q_drugs)
   })
   
   r_kmeans_thresholds=reactive(
     {
       score= r_score();
       kmo=kmeans(score,input$clusters)
       thresh = sapply(1:kmo$iter,function(cluster){
         min(score[kmo$cluster==cluster])
       })
       thresh=thresh[order(thresh)]
     }
   )
   
   r_drugs_orfs_table=reactive({
     thresh=as.integer(input$thresholdChoices)
     q_drugs_where = paste0("WHERE h.tax_id = ",r_tax_id(), ' and score >= ', thresh)
     q_drugs_orfs= paste0(q_drugs_orfs, q_drugs_where, q_drugs_orfs_group_by)
     drugs_orfs = dbGetQuery(conn, q_drugs_orfs)
   })
   observe({
     button_choices=r_kmeans_thresholds()
     labels=sapply(button_choices,function(thresh){paste('Threshold', thresh)})     
     updateRadioButtons(session, "thresholdChoices", choices = button_choices, 
                        selected = button_choices[button_choices==max(button_choices)])
   })
   
   
   output$distPlot <- renderPlot({
      # generate bins based on input$bins from ui.R
      score    <- r_score() #faithful$eruptions
      bins <- seq(min(log(score)), max(log(score)), length.out = input$bins + 1)
      
      # draw the histogram with the specified number of bins
      hist(log(score), breaks = bins, col = 'darkgray', border = 'white')
   })
   output$kmeansPlot<-renderPlot({
     organism = organisms$organism[organisms$tax_id==r_tax_id()]
     thresh = r_kmeans_thresholds()
     score = r_score()
     kmo = kmeans(score, length(thresh)+1)
     plot(score,col=kmo$cluster, main=paste('kmeans for ',organism ))
     for (threshold in thresh){
       abline(h=threshold,col='purple', lwd=2)
     }
     
   })
   output$queryThreshold = renderText(paste('Query Threshold:', as.integer(input$thresholdChoices)))
   
   output$drugsTable=renderDataTable({
     r_drugs_table()
    })
   
   output$orfQueryThreshold = renderText(paste('Query Threshold:', as.integer(input$thresholdChoices)))
   output$drugsOrfsTable=renderDataTable({
     r_drugs_orfs_table()
   });
   
   output$downloadDrugs<-downloadHandler(
     filename = function(){
       return(paste0(organisms$organism[organisms$tax_id==r_tax_id()],'.tsv'))
              },
     content = function(file){
       write.table(r_drugs_table(), file, sep = '\t', row.names = FALSE, quote = FALSE)
     }
   )
   
   output$downloadDrugsOrfs<-downloadHandler(
     filename = function(){
       return(paste0(organisms$organism[organisms$tax_id==r_tax_id()],'_orfs.tsv'))
     },
     content = function(file){
       write.table(r_drugs_orfs_table(), file, sep = '\t', row.names = FALSE, quote = FALSE)
     }
   )
}

# Run the application 
shinyApp(ui = ui, server = server)

