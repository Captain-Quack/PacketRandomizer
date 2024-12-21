
# Quizbowl Packet Randomizer

A **Shiny app** for generating randomized **Quizbowl packets** based on user-defined categories and subcategories. The app ensures balanced distribution and adheres to adjacency rules for fairness.

---

## Features
- **Randomized Packet Generation:** Create single Quizbowl packets with 20 **tossups (TU)** and 20 **bonuses (B)**.
- **Balanced Categories:** Each packet evenly distributes **five categories** across **four quarters** with no adjacency violations.
- **Custom Categories:** Users can define categories and subcategories for **History**, **Science**, **Literature**, **Fine Arts & Other**, and **RMPSS**.
- **Clipboard Copy:** Instantly copy the generated packet to your clipboard.
- **Tournament Packet Downloads:** Generate and download **multiple packets** in a ZIP file, ready for tournaments.

---

## Getting Started

### 1. Local Setup
1. **Install Required Packages:**
   ```r
   install.packages(c("shiny", "zip"))
   ```
2. **Run the App Locally:**
   ```r
   library(shiny)
   runApp()
   ```
3. **Access the App:**  
   Opens in your **default browser** at:
   ```
   http://127.0.0.1:xxxx/
   ```

---

### 2. Hosting on Shiny Server (Optional)
Follow instructions in the [Shiny Server Guide](https://rstudio.com/products/shiny/shiny-server/) or use **Docker** for hosting on your network.

---

## Using the App

### A. Generate a Single Packet
1. Enter **four subcategories** for each category (comma-separated).
2. Click **"Display Single Packet"** to generate.
3. View the randomized packet and use **"Copy to Clipboard"** to copy it.

### B. Generate Tournament Packets
1. Enter the **tournament name** and the **number of packets**.
2. Click **"Download Packets"** to save a **ZIP file** containing randomized packets.

---

## Customization

### Categories
- **History:** American, European, Other, World
- **Science:** Biology, Chemistry, Physics, Other
- **Literature:** American, British, Euro/Ancient, World
- **Fine Arts & Other:** Painting/Sculpture, Music, Other, Geo/CE/Other
- **RMPSS:** Religion, Mythology, Philosophy, Social Science

**Note:** Each category must have **exactly 4 subcategories**.

---

## Randomization Rules

1. **Built by Quarters for Balance:**
   - The app divides the packet into **4 quarters** with **5 questions** each.
   - Each quarter contains **one question** from each **major category** (History, Science, Literature, Fine Arts & Other, and RMPSS) to ensure **balanced distribution**.

2. **No Adjacent Questions from the Same Category:**
   - Questions within and across quarters are randomized to **prevent consecutive questions** from sharing the **same category**.

3. **Distinct Subcategories for Tossups (TU) and Bonuses (B):**
   - Tossups and bonuses are paired randomly, ensuring that **no pair shares the same subcategory** (e.g., both TU1 and B1 cannot be **Biology**).

4. **Quarter-Level Shuffling:**
   - Questions are **shuffled within each quarter** after initial assignment to further **prevent adjacency violations**.

---


## Troubleshooting

The app currently times out when hosted on Shiny.io. It is unclear why.

---

## Example Output

```
TU1. Science : Other
TU2. Literature : Euro/Ancient
TU3. FineArtsOther : Other
TU4. RMPSS : Social Science
TU5. History : American
TU6. RMPSS : Religion
TU7. Science : Chemistry
TU8. History : World
TU9. Literature : World
TU10. FineArtsOther : Music
TU11. History : European
TU12. Literature : American
TU13. RMPSS : Philosophy
TU14. FineArtsOther : Geo/CE/Other
TU15. Science : Biology
TU16. RMPSS : Mythology
TU17. Literature : British
TU18. History : Other
TU19. FineArtsOther : Painting/Sculpture
TU20. Science : Physics
B1. Literature : Euro/Ancient
B2. Science : Chemistry
B3. RMPSS : Philosophy
B4. FineArtsOther : Other
B5. History : Other
B6. Literature : British
B7. FineArtsOther : Painting/Sculpture
B8. Science : Biology
B9. RMPSS : Mythology
B10. History : World
B11. RMPSS : Social Science
B12. History : European
B13. FineArtsOther : Music
B14. Literature : World
B15. Science : Other
B16. History : American
B17. FineArtsOther : Geo/CE/Other
B18. RMPSS : Religion
B19. Science : Physics
B20. Literature : American
```

---

## Acknowledgments

This app was developed to streamline **Quizbowl packet creation** for editors and writers

---

## License

This project is licensed under the **GNU General Public License**—feel free to modify and distribute!
