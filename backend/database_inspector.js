// State Store
const state = {
    tables: {}, // { "schema.tableName": { schema: '', tableName: '', rows: [], columns: [], loaded: false } }
    activeTable: 'student.students',
};

// Fetch Live Tables from PostgreSQL API
async function loadAllData() {
    const statusEl = document.getElementById('statusMessage');
    if (statusEl) statusEl.innerText = 'Fetching live PostgreSQL database tables...';
    
    // Clear loaded state so refresh fetches clean data from AWS RDS
    for (const key in state.tables) {
        state.tables[key].loaded = false;
        state.tables[key].rows = [];
    }

    try {
        const res = await fetch('/api/db/meta/tables');
        if (res.ok) {
            const data = await res.json();
            if (data && data.tables && Array.isArray(data.tables)) {
                data.tables.forEach(t => {
                    const schemaName = t.table_schema || 'public';
                    const tableName = t.table_name;
                    const fullName = `${schemaName}.${tableName}`;
                    
                    if (!state.tables[fullName]) {
                        state.tables[fullName] = {
                            schema: schemaName,
                            tableName: tableName,
                            rows: [],
                            columns: [],
                            loaded: false
                        };
                    }
                });
                if (statusEl) statusEl.innerText = `Connected! Total ${Object.keys(state.tables).length} tables & views in AWS PostgreSQL.`;
            }
        }
    } catch (e) {
        if (statusEl) statusEl.innerText = `Error connecting to API: ${e.message}`;
    }

    const tableNames = Object.keys(state.tables).sort();
    if (tableNames.length > 0 && (!state.activeTable || !state.tables[state.activeTable])) {
        state.activeTable = tableNames.includes('student.students') ? 'student.students' : tableNames[0];
    }

    renderSidebar();
    await fetchActiveTableRows(state.activeTable, true);
}

async function fetchActiveTableRows(fullName, force = false) {
    if (!fullName || !state.tables[fullName]) return;

    const tData = state.tables[fullName];
    if (!force && tData.loaded && tData.rows.length > 0) {
        renderActiveTable();
        return;
    }

    try {
        const url = `/api/db/${tData.schema}/${tData.tableName}?limit=100&_t=${Date.now()}`;
        const res = await fetch(url, { cache: 'no-store' });
        if (res.ok) {
            const rows = await res.json();
            if (Array.isArray(rows)) {
                tData.rows = rows;
                tData.columns = rows.length > 0 ? Object.keys(rows[0]) : (tData.columns || []);
                tData.loaded = true;
            }
        }
    } catch (_) {}

    renderSidebar();
    renderActiveTable();
}

// Render Sidebar
function renderSidebar() {
    const filterInput = document.getElementById('tableFilter');
    const filter = filterInput ? filterInput.value.toLowerCase() : '';
    const container = document.getElementById('tablesList');
    if (!container) return;

    container.innerHTML = '';

    const tableNames = Object.keys(state.tables).sort();

    tableNames.forEach(fullName => {
        if (filter && !fullName.toLowerCase().includes(filter)) return;

        const tData = state.tables[fullName];
        const rowsCount = tData.rows ? tData.rows.length : 0;
        const isActive = fullName === state.activeTable;

        const btn = document.createElement('button');
        btn.className = `table-btn ${isActive ? 'active' : ''}`;
        btn.onclick = async () => {
            state.activeTable = fullName;
            renderSidebar();
            await fetchActiveTableRows(fullName);
        };

        btn.innerHTML = `
            <span class="table-name">
                <span style="font-size:0.68rem;color:#6366F1;font-weight:700;margin-right:4px;">${tData.schema}.</span>${tData.tableName}
            </span>
            <span class="row-badge">${rowsCount}</span>
        `;
        container.appendChild(btn);
    });

    const countBadge = document.getElementById('tableCountBadge');
    if (countBadge) countBadge.innerText = `${tableNames.length} TABLES`;
}

// Render Table Grid
function renderActiveTable() {
    const fullName = state.activeTable;
    const tableData = state.tables[fullName];

    const titleEl = document.getElementById('activeTableName');
    if (titleEl) titleEl.innerText = fullName || 'Select a table';
    
    if (!tableData) {
        document.getElementById('tableHead').innerHTML = '';
        document.getElementById('tableBody').innerHTML = '<tr><td style="text-align:center;padding:40px;">No table selected</td></tr>';
        document.getElementById('rowCountPill').innerText = '0 Rows';
        document.getElementById('colCountPill').innerText = '0 Cols';
        return;
    }

    let cols = tableData.columns || [];
    if (cols.length === 0 && tableData.rows && tableData.rows.length > 0) {
        cols = Object.keys(tableData.rows[0]);
        tableData.columns = cols;
    }

    const rowPill = document.getElementById('rowCountPill');
    const colPill = document.getElementById('colCountPill');
    if (rowPill) rowPill.innerText = `${tableData.rows.length} Rows`;
    if (colPill) colPill.innerText = `${cols.length} Cols`;

    // Render Header
    let headHtml = '<tr><th style="width:40px;">#</th>';
    cols.forEach(c => {
        headHtml += `<th>${c}</th>`;
    });
    headHtml += '<th>Inspect</th></tr>';
    const headEl = document.getElementById('tableHead');
    if (headEl) headEl.innerHTML = headHtml;

    renderTableBody();
}

function renderTableBody() {
    const fullName = state.activeTable;
    const tableData = state.tables[fullName];
    if (!tableData) return;

    const rowSearchInput = document.getElementById('rowSearch');
    const filter = rowSearchInput ? rowSearchInput.value.toLowerCase() : '';
    const cols = tableData.columns || [];
    const body = document.getElementById('tableBody');
    if (!body) return;

    const rows = (tableData.rows || []).filter(row => {
        if (!filter) return true;
        return Object.values(row).some(v => String(v).toLowerCase().includes(filter));
    });

    if (rows.length === 0) {
        body.innerHTML = `<tr><td colspan="${cols.length + 2}" style="text-align:center;padding:40px;color:#94A3B8;">No records found in table "${fullName}"</td></tr>`;
        return;
    }

    let html = '';
    rows.forEach((row, idx) => {
        html += `<tr><td style="color:#94A3B8;">${idx + 1}</td>`;
        cols.forEach(c => {
            let val = row[c];
            if (val === null || val === undefined) val = '<span style="color:#CBD5E1;">null</span>';
            else if (typeof val === 'object') val = JSON.stringify(val);
            html += `<td>${val}</td>`;
        });
        html += `<td><button class="btn-inspect" onclick="inspectRow(${idx})">Inspect</button></td></tr>`;
    });

    body.innerHTML = html;
}

function inspectRow(idx) {
    const tableData = state.tables[state.activeTable];
    if (!tableData || !tableData.rows[idx]) return;
    const rowData = tableData.rows[idx];
    document.getElementById('modalTitle').innerText = `${state.activeTable} - Record #${idx + 1}`;
    document.getElementById('modalJson').innerText = JSON.stringify(rowData, null, 2);
    document.getElementById('jsonModal').classList.add('active');
}

function closeModal() {
    document.getElementById('jsonModal').classList.remove('active');
}

// Attach Event Listeners & Initialize
window.addEventListener('DOMContentLoaded', () => {
    loadAllData();
});

// Execute immediately if DOM is already ready
if (document.readyState === 'complete' || document.readyState === 'interactive') {
    loadAllData();
}
