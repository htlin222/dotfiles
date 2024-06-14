"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const RemarkParse = require("remark-parse");
const RemarkStringify = require("remark-stringify");
const RemarkWikiLink = require("remark-wiki-link");
const unified = require("unified");
// TODO adopt the more general parser in incremental-thinking
function allLinksHaveTitles() {
    const Compiler = this.Compiler;
    const visitors = Compiler.prototype.visitors;
    const original = visitors.link;
    visitors.link = function (linkNode) {
        return original.bind(this)({
            ...linkNode,
            title: linkNode.title || ""
        });
    };
}
const processor = unified()
    .use(RemarkParse, { commonmark: true, pedantic: true }) // type decl doesn't have options
    .use(RemarkStringify, {
    bullet: "*",
    emphasis: "*",
    listItemIndent: "1",
    rule: "-",
    ruleSpaces: false
})
    .use(allLinksHaveTitles)
    .use(RemarkWikiLink);
exports.default = processor;
//# sourceMappingURL=processor.js.map