// Footnote system: Automatically processes <footnote> tags
// Creates numbered superscripts with bidirectional links

document.addEventListener('DOMContentLoaded', function() {
  const content = document.querySelector('.content');
  if (!content) return;

  // Find all footnote elements
  const footnoteElements = content.querySelectorAll('footnote');
  if (footnoteElements.length === 0) return;

  // Create footnotes section
  const footnotesSection = document.createElement('section');
  footnotesSection.className = 'footnotes';
  footnotesSection.innerHTML = '<hr><ol class="footnotes-list"></ol>';
  const referencesSection = document.getElementById('references');
  if (referencesSection) {
    content.insertBefore(footnotesSection, referencesSection);
  } else {
    content.appendChild(footnotesSection);
  }

  const footnotesList = footnotesSection.querySelector('.footnotes-list');

  // Process each footnote
  footnoteElements.forEach((footnote, index) => {
    const num = index + 1;
    const refId = `fnref${num}`;
    const noteId = `fn${num}`;

    // Create superscript reference link
    const sup = document.createElement('sup');
    const refLink = document.createElement('a');
    refLink.href = `#${noteId}`;
    refLink.id = refId;
    refLink.className = 'footnote-ref';
    refLink.textContent = num;
    sup.appendChild(refLink);

    // Replace footnote element with superscript
    footnote.parentNode.replaceChild(sup, footnote);

    // Create footnote list item
    const li = document.createElement('li');
    li.id = noteId;
    li.innerHTML = footnote.innerHTML;

    // Add back-reference link
    const backLink = document.createElement('a');
    backLink.href = `#${refId}`;
    backLink.className = 'footnote-back';
    backLink.innerHTML = '&#8617;'; // ↩ arrow (no leading space)
    backLink.setAttribute('aria-label', 'Back to content');
    li.appendChild(backLink);

    footnotesList.appendChild(li);
  });

  // Trigger MathJax to render LaTeX in footnotes
  if (window.MathJax && window.MathJax.typesetPromise) {
    MathJax.typesetPromise([footnotesList]).catch((err) => console.error('MathJax error:', err));
  }
});
