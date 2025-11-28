data <- read.csv("xforms/subs-nov2025.csv", stringsAsFactors = FALSE)

# Calculate engagement scores
data$engagement_score <- 
  data$num_emails_opened + 
  (data$Links.clicked * 2) + 
  (data$Comments * 3) + 
  (data$Shares * 2)

# 1. Non-free subscribers (Paid + Comp + Author) + upgrade candidates
non_free_base <- data[data$Type %in% c("Yearly Subscriber", "Comp", "Author"), ]
top25 <- head(data[order(-data$engagement_score), ], 25)

# Find free subscribers who are in top 25 (upgrade candidates)
upgrade_candidates <- top25[top25$Type == "Free", ]

# Combine non-free with upgrade candidates
paid2rant_list <- rbind(non_free_base, upgrade_candidates)
paid2rant_list <- paid2rant_list[order(-paid2rant_list$engagement_score), ]

cat("Non-free subscribers (base):", nrow(non_free_base), "\n")
cat("Upgrade candidates (free but top 25):", nrow(upgrade_candidates), "\n")
cat("Total in paid2rant.R:", nrow(paid2rant_list), "\n\n")

# Write paid2rant.R to xforms/
writeLines(c(
  "# Non-free subscribers + Upgrade candidates",
  paste0("# Non-free (Paid + Comp + Author): ", nrow(non_free_base)),
  paste0("# Upgrade candidates (Free but top 25): ", nrow(upgrade_candidates)),
  paste0("# Total: ", nrow(paid2rant_list), " subscribers"),
  paste0("# Generated: ", Sys.Date()),
  "",
  "recipients <- c(",
  paste0('  "', paid2rant_list$Email, '"', collapse = ",\n"),
  ")"
), "xforms/paid2rant.R")

cat("Created: xforms/paid2rant.R\n\n")

# Show upgrade candidates
cat("Upgrade candidates added:\n")
uc_display <- upgrade_candidates[order(-upgrade_candidates$engagement_score), 
                                  c("Email", "Name", "engagement_score")]
for(i in 1:nrow(uc_display)) {
  cat(sprintf("%2d. %-40s %-20s Score: %3d\n", 
              i, 
              uc_display$Email[i], 
              ifelse(is.na(uc_display$Name[i]) | uc_display$Name[i] == "", "(no name)", uc_display$Name[i]),
              uc_display$engagement_score[i]))
}

# 2. High engagement - top 25
high_engagement <- top25

cat("\n\nHigh engagement subscribers: top 25\n")
cat("Score range:", min(high_engagement$engagement_score), "-", max(high_engagement$engagement_score), "\n")

# Write high_engagement.R to xforms/
writeLines(c(
  "# High engagement subscribers (top 25)",
  paste0("# Total: 25 subscribers"),
  "# Scoring: opens + (clicks * 2) + (comments * 3) + (shares * 2)",
  paste0("# Generated: ", Sys.Date()),
  "",
  "recipients <- c(",
  paste0('  "', high_engagement$Email, '"', collapse = ",\n"),
  ")"
), "xforms/high_engagement.R")

cat("\nCreated: xforms/high_engagement.R\n")
