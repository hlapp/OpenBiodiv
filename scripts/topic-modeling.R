library(tm)
library(tidytext)
library(ggplot2)
library(dplyr)
txt <- "/media/obkms/nactem/pensoft-clean/pensoft-clean/"

# Corpus preparation
pensoft <- VCorpus(DirSource(txt, encoding = "UTF-8"), readerControl = list(language = "eng")) # reads a volatile (persists until object is there) corpus
pensoft <- tm_map(pensoft, FUN = stripWhitespace) # removes whitespace
pensoft <- tm_map(pensoft, FUN = content_transformer(FUN = tolower)) # converts to lower case
pensoft <- tm_map(pensoft, FUN = removeWords, words = stopwords("english")) # removes stopwords
pensoft <- tm_map(pensoft, FUN = stemDocument) # stemming (takes time)

inspect(pensoft[[1]])

# Document-term matrix

dtm <- DocumentTermMatrix(pensoft) # takes time

# Latent Dirichlet Allocation (model fitting stage)

pen_lda <- LDA(dtm, k = 10, control = list(seed = 1234)) # 10 topics, takes lots of time

# topics

pen_topics <- tidy(pen_lda, matrix = "beta")

# A lot of crap: more cleaning needed
# A tibble: 4,042,664 x 3
# topic  term         beta
# <int> <chr>        <dbl>
#   1     1   ×”. 9.547177e-08
# 2     2   ×”. 3.943064e-11
# 3     1   ×), 3.820344e-07
# 4     2   ×), 9.119881e-18
# 5     1   ×); 1.957926e-06
# 6     2   ×); 1.944648e-21
# 7     1   ×). 7.106020e-07
# 8     2   ×). 5.726397e-08
# 9     1   <<) 2.861347e-08
# 10     2   <<) 2.050022e-08
# # ... with 4,042,654 more rows


top_terms <- pen_topics %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)
