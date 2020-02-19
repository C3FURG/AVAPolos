"use strict";
/**
 * Copyright (c) 2017 The xterm.js authors. All rights reserved.
 * @license MIT
 */

 // forked on 10-22-19

const MINIMUM_COLS = 2;
const MINIMUM_ROWS = 1;
class FitAddon {
    constructor() { }
    activate(terminal) {
        this._terminal = terminal;
    }
    dispose() { }
    fit() {
        const dims = this.proposeDimensions();
        if (!dims || !this._terminal) {
            return;
        }
        // TODO: Remove reliance on private API
        const core = this._terminal._core;
        // Force a full render
        if (this._terminal.rows !== dims.rows || this._terminal.cols !== dims.cols) {
            core._renderService.clear();
            this._terminal.resize(dims.cols, dims.rows);
        }
    }
    proposeDimensions() {
        if (!this._terminal) {
            return undefined;
        }
        if (!this._terminal.element || !this._terminal.element.parentElement) {
            return undefined;
        }
        // TODO: Remove reliance on private API
        const core = this._terminal._core;
        const parentElementStyle = window.getComputedStyle(this._terminal.element.parentElement);
        const parentElementHeight = parseInt(parentElementStyle.getPropertyValue('height'));
        const parentElementWidth = Math.max(0, parseInt(parentElementStyle.getPropertyValue('width')));
        const elementStyle = window.getComputedStyle(this._terminal.element);
        const elementPadding = {
            top: parseInt(elementStyle.getPropertyValue('padding-top')),
            bottom: parseInt(elementStyle.getPropertyValue('padding-bottom')),
            right: parseInt(elementStyle.getPropertyValue('padding-right')),
            left: parseInt(elementStyle.getPropertyValue('padding-left'))
        };
        const elementPaddingVer = elementPadding.top + elementPadding.bottom;
        const elementPaddingHor = elementPadding.right + elementPadding.left;
        const availableHeight = parentElementHeight - elementPaddingVer;
        const availableWidth = parentElementWidth - elementPaddingHor - core.viewport.scrollBarWidth;
        const geometry = {
            cols: Math.max(MINIMUM_COLS, Math.floor(availableWidth / core._renderService.dimensions.actualCellWidth)),
            rows: Math.max(MINIMUM_ROWS, Math.floor(availableHeight / core._renderService.dimensions.actualCellHeight))
        };
        return geometry;
    }
}
