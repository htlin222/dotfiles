"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const visitParents = require("unist-util-visit-parents");
const getBacklinksBlock_1 = require("./getBacklinksBlock");
const blockTypes = [
    "paragraph",
    "heading",
    "thematicBreak",
    "blockquote",
    "list",
    "table",
    "html",
    "code"
];
function isBlockContent(node) {
    return blockTypes.includes(node.type);
}
function getNoteLinks(tree) {
    // Strip out the backlinks section
    const backlinksInfo = getBacklinksBlock_1.default(tree);
    let searchedChildren;
    if (backlinksInfo.isPresent) {
        searchedChildren = tree.children
            .slice(0, tree.children.findIndex(n => n === backlinksInfo.start))
            .concat(tree.children.slice(backlinksInfo.until
            ? tree.children.findIndex(n => n === backlinksInfo.until)
            : tree.children.length));
    }
    else {
        searchedChildren = tree.children;
    }
    const links = [];
    visitParents({ ...tree, children: searchedChildren }, "wikiLink", (node, ancestors) => {
        const closestBlockLevelAncestor = ancestors.reduceRight((result, needle) => (result !== null && result !== void 0 ? result : (isBlockContent(needle) ? needle : null)), null);
        links.push({
            targetTitle: node.data.alias,
            context: closestBlockLevelAncestor
        });
        return true;
    });
    return links;
}
exports.default = getNoteLinks;
//# sourceMappingURL=getNoteLinks.js.map