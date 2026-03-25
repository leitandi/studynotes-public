// Automatically generate table of contents from headers
document.addEventListener("DOMContentLoaded", function () {
  const content = document.querySelector(".content");
  const tocList = document.getElementById("toc-list");

  if (!content || !tocList) return;

  // Get all headers (h1, h2) within the content div, excluding the TOC header
  const headers = content.querySelectorAll("h1, h2");
  const tocHeaders = Array.from(headers).filter(
    (h) => h.parentElement.id !== "table-of-contents" && !h.hasAttribute("data-toc-ignore")
  );

  // Add IDs to headers if they don't have one
  tocHeaders.forEach((header, index) => {
    if (!header.id) {
      // Create a slug from the header text
      const slug = header.textContent
        .toLowerCase()
        .trim()
        .replace(/[^\w\s-]/g, "") // Remove special characters
        .replace(/\s+/g, "-") // Replace spaces with hyphens
        .replace(/-+/g, "-"); // Replace multiple hyphens with single hyphen

      header.id = slug || `section-${index}`;
    }
  });

  // Build nested structure
  const tocTree = [];
  let currentH1 = null;

  tocHeaders.forEach((header) => {
    const level = parseInt(header.tagName[1]);
    const item = {
      text: header.textContent,
      id: header.id,
      level: level,
      children: [],
    };

    if (level === 1) {
      tocTree.push(item);
      currentH1 = item;
    } else if (level === 2) {
      if (currentH1) {
        currentH1.children.push(item);
      } else {
        tocTree.push(item);
      }
    }
  });

  // Render the TOC
  function renderTocItem(item) {
    const li = document.createElement("li");
    const link = document.createElement("a");
    link.href = `#${item.id}`;
    link.textContent = item.text;
    li.appendChild(link);

    if (item.children && item.children.length > 0) {
      const ul = document.createElement("ul");
      item.children.forEach((child) => {
        ul.appendChild(renderTocItem(child));
      });
      li.appendChild(ul);
    }

    return li;
  }

  tocTree.forEach((item) => {
    tocList.appendChild(renderTocItem(item));
  });

  function setupCollapsibleSection(containerId, headerId, toggleId) {
    const container = document.getElementById(containerId);
    const header = document.getElementById(headerId);
    const toggle = document.getElementById(toggleId);

    if (!container || !header || !toggle) return;

    function syncState() {
      const expanded = !container.classList.contains("collapsed");
      toggle.setAttribute("aria-expanded", expanded ? "true" : "false");
    }

    header.addEventListener("click", function () {
      container.classList.toggle("collapsed");
      syncState();
    });

    syncState();
  }

  // Add toggle functionality
  setupCollapsibleSection("table-of-contents", "toc-header", "toc-toggle");
  setupCollapsibleSection("references", "references-header", "references-toggle");
});
