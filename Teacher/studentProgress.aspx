<%@ Page Title="Student Progress" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="studentProgress.aspx.cs" Inherits="ScienceBuddy.Teacher.studentProgress" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Teacher.css") %>" rel="stylesheet" />
</asp:Content>

<%-- Sidebar --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i>
            <span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bell item-icon"></i>
            <span class="item-label"><%: T("Notifications","Notifikasi") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-book item-icon"></i>
            <span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-patch-question item-icon"></i>
            <span class="item-label"><%: T("Manage Quiz","Kuiz") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-bar-chart item-icon"></i>
            <span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-camera-video item-icon"></i>
            <span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Forum.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i>
            <span class="item-label"><%: T("Forum","Forum") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-envelope item-icon"></i>
            <span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i>
            <span class="item-label"><%: T("My Profile","Profil Saya") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-box-arrow-right item-icon"></i>
            <span class="item-label"><%: T("Sign Out","Log Keluar") %></span>
        </a>
    </div>

</asp:Content>

<%-- Page Title --%>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <%: T("Student Progress","Prestasi Pelajar") %>
</asp:Content>

<%-- Main Content --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

    <%-- Pending Verification State --%>
    <asp:Panel ID="pnlPending" runat="server" Visible="false">
        <div style="display:flex;flex-direction:column;align-items:center;padding:3.5rem 2rem;text-align:center;">
            <div style="font-size:3.5rem;margin-bottom:1rem;opacity:.85;">?</div>
            <h2 style="font-size:1.15rem;font-weight:800;color:var(--tc-student-progress-t);margin:0 0 .6rem;">
                <%: T("Verification Pending","Pengesahan Sedang Diproses") %>
            </h2>
            <p style="font-size:.88rem;color:var(--tc-student-progress-m);max-width:480px;line-height:1.65;margin:0;">
                <%: T("Your Teaching License is still under review. You will be able to view student progress once your verification has been approved.","Lesen Mengajar anda masih dalam semakan. Anda akan dapat melihat prestasi pelajar setelah pengesahan anda diluluskan.") %>
            </p>
        </div>
    </asp:Panel>

    <%-- Main Content (hidden for Pending teachers) --%>
    <asp:Panel ID="pnlContent" runat="server">

        <%-- Podium --%>
        <asp:Panel ID="pnlPodium" runat="server" Visible="false">
            <div class="tc-student-progress-podium-section">
                <div class="tc-student-progress-podium-hd">
                    <h2><i class="bi bi-trophy-fill"></i> <%: T("Top Performing Students","Pelajar Terbaik") %></h2>
                    <div class="tc-student-progress-podium-hd-line"></div>
                    <p><%: T("Top 3 students based on overall performance","3 pelajar terbaik berdasarkan prestasi keseluruhan") %></p>
                </div>

                <div class="tc-student-progress-podium">
                    <asp:Repeater ID="rptPodium" runat="server">
                        <ItemTemplate>
                            <div class='tc-student-progress-pod <%# Eval("podCss") %>'>
                                <%# Convert.ToBoolean(Eval("hasData")) ? "<span class='tc-student-progress-pod-medal'>" + Eval("medal") + "</span><div class='tc-student-progress-pod-avatar'>" + HttpUtility.HtmlEncode(Eval("initials").ToString()) + "</div><div class='tc-student-progress-pod-name'>" + HttpUtility.HtmlEncode(Eval("name").ToString()) + "</div><div class='tc-student-progress-pod-pct'>" + Eval("overallStr") + "</div><span class='tc-student-progress-pod-badge " + Eval("perfCss") + "'>" + Eval("perfLabel") + "</span><div class='tc-student-progress-pod-lessons'><i class='bi bi-book'></i> " + Eval("lessonsStr") + "</div>" : "<div class='tc-student-progress-pod-empty'><span class='tc-student-progress-pod-medal'>" + Eval("medal") + "</span><br/><span style='display:block;margin-top:.4rem;font-weight:600;'>No student yet</span><span style='font-size:.72rem;color:#9CA3AF;'>Complete more quizzes to appear here.</span></div>" %>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="tc-student-progress-bases">
                    <div class="tc-student-progress-base tc-base-2"></div>
                    <div class="tc-student-progress-base tc-base-1"></div>
                    <div class="tc-student-progress-base tc-base-3"></div>
                </div>
            </div>
        </asp:Panel>

        <%-- Search --%>
        <div class="tc-student-progress-search-card">
            <div class="tc-student-progress-search-row">
                <div class="tc-student-progress-search-wrap">
                    <i class="bi bi-search"></i>
                    <input type="text"
                        id="spSearchInput"
                        class="tc-student-progress-search-input"
                        placeholder="<%: T("Search student...","Cari pelajar...") %>"
                        value="<%= HttpUtility.HtmlAttributeEncode(txtSearch.Text) %>" />
                </div>
                <asp:DropDownList ID="ddlSort" runat="server"
                    CssClass="tc-student-progress-sort"
                    onchange="spFilterTable();return false;" />
                <button type="button" class="tc-student-progress-btn" onclick="spFilterTable()">
                    <%: T("Search","Cari") %>
                </button>
                <button type="button" class="tc-student-progress-btn-reset" onclick="spResetFilter()">
                    <%: T("Reset","Set Semula") %>
                </button>
            </div>
        </div>
        <asp:TextBox ID="txtSearch" runat="server" Style="display:none;" />

        <%-- Table --%>
        <div class="tc-student-progress-rank-card">
            <div class="tc-student-progress-rank-hd">
                <i class="bi bi-trophy"></i>
                <h2><%: T("Student Progress Summary","Ringkasan Prestasi Pelajar") %></h2>
            </div>

            <asp:Panel ID="pnlRankingEmpty" runat="server" Visible="false">
                <div class="tc-student-progress-empty">
                    <i class="bi bi-people"></i>
                    <div class="tc-student-progress-empty-title">
                        <%: T("No students found.","Tiada pelajar ditemui.") %>
                    </div>
                    <div class="tc-student-progress-empty-sub">
                        <%: T("Try searching another student name.","Cuba cari nama pelajar lain.") %>
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlTable" runat="server" Visible="false">
                <table class="tc-student-progress-tbl">
                    <thead>
                        <tr>
                            <th style="width:50px;">No.</th>
                            <th><%: T("Student","Pelajar") %></th>
                            <th><%: T("Lessons","Pelajaran") %></th>
                            <th><%: T("Unit Quiz Average","Purata Kuiz Unit") %></th>
                            <th><%: T("Level Quiz Average","Purata Kuiz Tahap") %></th>
                            <th><%: T("Overall","Keseluruhan") %></th>
                            <th><%: T("Action","Tindakan") %></th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptRanking" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><span class="tc-student-progress-no"><%# Eval("rowNum") %></span></td>
                                    <td><%# HttpUtility.HtmlEncode(Eval("name").ToString()) %></td>
                                    <td><%# Eval("lessonsStr") %></td>
                                    <td>
                                        <%# Eval("unitQuizStr") %>
                                        <span class='tc-student-progress-q-badge <%# Eval("unitBadge") %>'><%# BadgeLabel(Eval("unitBadge").ToString()) %></span>
                                    </td>
                                    <td>
                                        <%# Eval("levelQuizStr") %>
                                        <span class='tc-student-progress-q-badge <%# Eval("levelBadge") %>'><%# BadgeLabel(Eval("levelBadge").ToString()) %></span>
                                    </td>
                                    <td><strong><%# Eval("overallStr") %></strong></td>
                                    <td>
                                        <a href='<%# ResolveUrl("~/Teacher/studentDetails.aspx") + "?studentId=" + Eval("studentId") %>'
                                            class="tc-student-progress-vd-btn">
                                            <i class="bi bi-eye"></i> <%: T("View Details","Lihat Butiran") %>
                                        </a>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </asp:Panel>
        </div>

    </asp:Panel>

</asp:Content>

<%-- Scripts --%>
<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script>
        function spFilterTable() {
            var query = document.getElementById('spSearchInput').value.trim().toLowerCase();
            var sortVal = document.getElementById('<%=ddlSort.ClientID%>').value;
            var table = document.querySelector('.tc-student-progress-tbl');
            if (!table) return;
            var tbody = table.querySelector('tbody');
            if (!tbody) return;
            var rows = Array.prototype.slice.call(tbody.querySelectorAll('tr'));

            // Sort rows
            if (sortVal) {
                rows.sort(function (a, b) {
                    var nameA = (a.cells[1] ? a.cells[1].textContent.trim() : '').toLowerCase();
                    var nameB = (b.cells[1] ? b.cells[1].textContent.trim() : '').toLowerCase();
                    var overallA = parseFloat((a.cells[5] ? a.cells[5].textContent : '0').replace('%', '')) || 0;
                    var overallB = parseFloat((b.cells[5] ? b.cells[5].textContent : '0').replace('%', '')) || 0;
                    var lessonsA = parseInt((a.cells[2] ? a.cells[2].textContent : '0').split('/')[0]) || 0;
                    var lessonsB = parseInt((b.cells[2] ? b.cells[2].textContent : '0').split('/')[0]) || 0;
                    if (sortVal === 'az') return nameA.localeCompare(nameB);
                    if (sortVal === 'za') return nameB.localeCompare(nameA);
                    if (sortVal === 'high') return overallB - overallA;
                    if (sortVal === 'low') return overallA - overallB;
                    if (sortVal === 'most') return lessonsB - lessonsA;
                    if (sortVal === 'least') return lessonsA - lessonsB;
                    return 0;
                });
                for (var i = 0; i < rows.length; i++) { tbody.appendChild(rows[i]); }
            }

            // Filter by search query
            var visibleCount = 0;
            for (var j = 0; j < rows.length; j++) {
                var name = rows[j].cells[1] ? rows[j].cells[1].textContent.toLowerCase() : '';
                if (!query || name.indexOf(query) > -1) { rows[j].style.display = ''; visibleCount++; }
                else { rows[j].style.display = 'none'; }
            }

            // Show/hide empty state
            var emptyPanel = document.getElementById('<%=pnlRankingEmpty.ClientID%>');
            var tablePanel = document.getElementById('<%=pnlTable.ClientID%>');
            if (emptyPanel && tablePanel) {
                if (visibleCount === 0 && rows.length > 0) { emptyPanel.style.display = 'block'; tablePanel.style.display = 'none'; }
                else { emptyPanel.style.display = 'none'; tablePanel.style.display = 'block'; }
            }
        }

        function spResetFilter() {
            document.getElementById('spSearchInput').value = '';
            document.getElementById('<%=ddlSort.ClientID%>').selectedIndex = 0;
            spFilterTable();
        }

        document.addEventListener('DOMContentLoaded', function () {
            var inp = document.getElementById('spSearchInput');
            if (inp) {
                inp.addEventListener('keydown', function (e) { if (e.key === 'Enter') { e.preventDefault(); spFilterTable(); } });
                inp.addEventListener('input', function () { spFilterTable(); });
            }
        });
    </script>
</asp:Content>
