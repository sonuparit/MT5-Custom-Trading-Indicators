let cleaned = "";

function process() {
  const input = document.getElementById("input").value;
  const rawKeywords = document.getElementById("keywords").value.split(",");
  const caseSensitive = document.getElementById("caseSensitive").checked;

  const keywords = rawKeywords.map((k) => k.trim()).filter((k) => k.length > 0);

  if (!keywords.length) {
    alert("Please enter at least one keyword.");
    return;
  }

  // Parse HTML
  const parser = new DOMParser();
  const doc = parser.parseFromString(input, "text/html");

  const rows = doc.querySelectorAll("tr");
  let removedCount = 0;
  let keywordMatches = {};

  rows.forEach((tr) => {
    const text = caseSensitive ? tr.textContent : tr.textContent.toLowerCase();

    for (const k of keywords) {
      const keyword = caseSensitive ? k : k.toLowerCase();
      if (text.includes(keyword)) {
        tr.remove();
        removedCount++;
        keywordMatches[keyword] = (keywordMatches[keyword] || 0) + 1;
        break; // prevent double-counting same row
      }
    }
  });

  cleaned = doc.body.innerHTML.trim();
  document.getElementById("output").textContent = cleaned;

  // summary report
  let summaryText = `Total <tr> removed: ${removedCount}\n\nKeyword matches:\n`;
  for (const [k, count] of Object.entries(keywordMatches)) {
    summaryText += `  "${k}" → ${count}\n`;
  }
  document.getElementById("summary").textContent = summaryText;
}

function download() {
  if (!cleaned) {
    alert("No cleaned HTML available. Click 'Process' first.");
    return;
  }
  const blob = new Blob([cleaned], { type: "text/html" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = "cleaned_table.html";
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}
