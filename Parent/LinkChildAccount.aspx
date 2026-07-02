<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LinkChildAccount.aspx.cs"
    Inherits="ScienceBuddy.Parent.LinkChildAccount" MasterPageFile="~/Site.Master"
    Title="Link Child Account" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.lc-page { padding: 24px 0; max-width: 720px; margin: 0 auto; }
.lc-card {
    background: #fff;
    border-radius: 20px;
    box-shadow: 0 2px 16px rgba(0,0,0,0.05);
    padding: 32px 36px;
    margin-bottom: 24px;
}
.lc-title {
    font-size: 1.2rem;
    font-weight: 800;
    color: #1E293B;
    margin: 0 0 4px;
    display: flex;
    align-items: center;
    gap: 8px;
}
.lc-title i { color: #2563EB; }
.lc-sub { font-size: 0.85rem; color: #64748B; margin-bottom: 24px; line-height: 1.5; }
.lc-field { margin-bottom: 18px; }
.lc-label {
    display: block;
    font-size: 0.8rem;
    font-weight: 700;
    color: #334155;
    margin-bottom: 5px;
}
.lc-input {
    width: 100%;
    border: 1.5px solid #E2E8F0;
    border-radius: 10px;
    padding: 10px 14px;
    font-size: 0.9rem;
    color: #1E293B;
    transition: border-color 0.15s;
    box-sizing: border-box;
    letter-spacing: 1px;
}
.lc-input:focus { border-color: #2563EB; outline: none; }
.lc-select {
    width: 100%;
    border: 1.5px solid #E2E8F0;
    border-radius: 10px;
    padding: 10px 14px;
    font-size: 0.9rem;
    color: #1E293B;
    background: #fff;
    appearance: auto;
}
.lc-select:focus { border-color: #2563EB; outline: none; }
.lc-btn {
    border: none;
    border-radius: 999px;
    padding: 10px 28px;
    font-size: 0.88rem;
    font-weight: 700;
    cursor: pointer;
    transition: background 0.15s, transform 0.1s;
    background: #2563EB;
    color: #fff;
}
.lc-btn:hover { background: #1D4ED8; transform: translateY(-1px); }
.lc-msg {
    border-radius: 10px;
    padding: 12px 16px;
    margin-bottom: 18px;
    font-size: 0.85rem;
    font-weight: 500;
}
.lc-msg.success { background: #ECFDF5; color: #065F46; }
.lc-msg.error { background: #FEF2F2; color: #991B1B; }
/* linked children list */
.lc-list-title {
    font-size: 1rem;
    font-weight: 700;
    color: #1E293B;
    margin: 0 0 14px;
    display: flex;
    align-items: center;
    gap: 7px;
}
.lc-list-title i { color: #2563EB; }
.lc-child-row {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 14px;
    border-radius: 12px;
    background: #F8FAFC;
    margin-bottom: 8px;
    border-left: 3px solid #DBEAFE;
}
.lc-child-avatar {
    width: 38px; height: 38px;
    border-radius: 50%;
    background: linear-gradient(135deg, #2563EB, #60A5FA);
    color: #fff;
    font-size: 0.85rem;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}
.lc-child-info { flex: 1; }
.lc-child-name { font-size: 0.9rem; font-weight: 600; color: #1E293B; }
.lc-child-rel { font-size: 0.75rem; color: #64748B; }
.lc-empty { text-align: center; padding: 20px; color: #94A3B8; font-size: 0.85rem; }
.lc-empty i { font-size: 2rem; display: block; margin-bottom: 8px; color: #CBD5E1; }
/* unlink button */
.lc-unlink-btn {
    font-size: 0.75rem;
    font-weight: 600;
    color: #DC2626;
    background: #FEF2F2;
    border: 1.5px solid #FECACA;
    border-radius: 999px;
    padding: 5px 12px;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 4px;
    margin-left: auto;
    flex-shrink: 0;
    transition: background 0.15s;
}
.lc-unlink-btn:hover { background: #FEE2E2; text-decoration: none; color: #991B1B; }

/* ── Unlink Confirmation Modal ─────────────────────────── */
.lc-modal-overlay {
    position: fixed;
    top: 0; left: 0; right: 0; bottom: 0;
    background: rgba(37,99,235,0.12);
    backdrop-filter: blur(3px);
    z-index: 9999;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 20px;
}
.lc-modal-card {
    background: #fff;
    border-radius: 20px;
    box-shadow: 0 16px 60px rgba(0,0,0,0.15);
    padding: 32px 36px;
    max-width: 400px;
    width: 100%;
    text-align: center;
}
.lc-modal-icon {
    width: 56px; height: 56px;
    border-radius: 50%;
    background: #FEF2F2;
    color: #DC2626;
    font-size: 1.5rem;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 16px;
}
.lc-modal-title {
    font-size: 1.1rem;
    font-weight: 800;
    color: #1E293B;
    margin-bottom: 8px;
}
.lc-modal-msg {
    font-size: 0.85rem;
    color: #64748B;
    line-height: 1.5;
    margin-bottom: 24px;
}
.lc-modal-actions {
    display: flex;
    gap: 12px;
    justify-content: center;
}
.lc-modal-btn {
    border: none;
    border-radius: 999px;
    padding: 10px 24px;
    font-size: 0.85rem;
    font-weight: 700;
    cursor: pointer;
    transition: background 0.15s, transform 0.1s;
}
.lc-modal-btn:hover { transform: translateY(-1px); }
.lc-modal-btn.cancel {
    background: #F1F5F9;
    color: #334155;
}
.lc-modal-btn.cancel:hover { background: #E2E8F0; }
.lc-modal-btn.danger {
    background: #DC2626;
    color: #fff;
}
.lc-modal-btn.danger:hover { background: #B91C1C; }
</style>
</asp:Content>

<%-- ════ SIDEBAR (full Parent sidebar) ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <%-- Child Switcher --%>
    <div style="padding:10px 16px 6px; font-size:0.72rem; color:#94A3B8; text-transform:uppercase; letter-spacing:1px; font-weight:700;">
        <%: T("Viewing Child","Anak Dilihat") %>
    </div>
    <div style="padding:0 16px 14px;">
        <asp:DropDownList ID="ddlSidebarChild" runat="server"
            AutoPostBack="true" OnSelectedIndexChanged="SidebarChildChanged"
            style="width:100%;border:1.5px solid #E2E8F0;border-radius:10px;padding:8px 12px;font-size:0.82rem;font-weight:600;color:#1D4ED8;background:#EFF6FF;" />
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentDashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i>
            <span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("My Children","Anak Saya") %></div>
        <a href="<%: ResolveUrl("~/Parent/LinkChildAccount.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-link-45deg item-icon"></i>
            <span class="item-label"><%: T("Link Child Account","Paut Akaun Anak") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/ChildProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person-badge item-icon"></i>
            <span class="item-label"><%: T("Child Profile","Profil Anak") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/EnrolledModules.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-journal-bookmark item-icon"></i>
            <span class="item-label"><%: T("Learning Journey","Perjalanan Pembelajaran") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Child Performance","Prestasi Anak") %></div>
        <a href="<%: ResolveUrl("~/Parent/ChildProgress.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bar-chart-line item-icon"></i>
            <span class="item-label"><%: T("Current Progress","Kemajuan Semasa") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/QuizResults.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-patch-check item-icon"></i>
            <span class="item-label"><%: T("Quiz Results","Keputusan Kuiz") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/ReportCard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-file-earmark-bar-graph item-icon"></i>
            <span class="item-label"><%: T("Report Card","Kad Laporan") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Study Plan","Pelan Pembelajaran") %></div>
        <a href="<%: ResolveUrl("~/Parent/StudyPlan.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-journal-check item-icon"></i>
            <span class="item-label"><%: T("Study Plan","Pelan Pembelajaran") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-journal-pen item-icon"></i>
            <span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i>
            <span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-people item-icon"></i>
            <span class="item-label"><%: T("Forum","Forum") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Notifications","Notifikasi") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentNotifications.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bell item-icon"></i>
            <span class="item-label"><%: T("Notifications","Notifikasi") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i>
            <span class="item-label"><%: T("Edit Profile","Edit Profil") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/AccountSettings.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-gear item-icon"></i>
            <span class="item-label"><%: T("Account Settings","Tetapan Akaun") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-box-arrow-right item-icon"></i>
            <span class="item-label"><%: T("Logout","Log Keluar") %></span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Link Child Account","Paut Akaun Anak") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="lc-page">

    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="lc-msg" id="divMsg" runat="server"></div>
    </asp:Panel>

    <%-- Link form --%>
    <div class="lc-card">
        <div class="lc-title"><i class="bi bi-link-45deg"></i> <asp:Literal ID="litTitle" runat="server" /></div>
        <div class="lc-sub"><asp:Literal ID="litSub" runat="server" /></div>

        <div class="lc-field">
            <label class="lc-label"><asp:Literal ID="litLblCode" runat="server" /></label>
            <asp:TextBox ID="txtCode" runat="server" CssClass="lc-input" MaxLength="20" placeholder="e.g. RAY468" />
        </div>

        <div class="lc-field">
            <label class="lc-label"><asp:Literal ID="litLblRelationship" runat="server" /></label>
            <asp:DropDownList ID="ddlRelationship" runat="server" CssClass="lc-select">
                <asp:ListItem Value="Mother" />
                <asp:ListItem Value="Father" />
                <asp:ListItem Value="Guardian" />
            </asp:DropDownList>
        </div>

        <asp:Button ID="btnLink" runat="server" CssClass="lc-btn"
            OnClick="BtnLink_Click" CausesValidation="false" />
    </div>

    <%-- Linked children list --%>
    <div class="lc-card">
        <div class="lc-list-title"><i class="bi bi-people-fill"></i> <asp:Literal ID="litLinkedTitle" runat="server" /></div>
        <asp:Panel ID="pnlLinkedList" runat="server"></asp:Panel>
        <asp:Panel ID="pnlNoLinked" runat="server" Visible="false">
            <div class="lc-empty">
                <i class="bi bi-person-x"></i>
                <asp:Literal ID="litNoLinked" runat="server" />
            </div>
        </asp:Panel>
    </div>

    <%-- Hidden field for unlink target --%>
    <asp:HiddenField ID="hidUnlinkArg" runat="server" />

    <%-- Unlink Confirmation Modal --%>
    <asp:Panel ID="pnlUnlinkModal" runat="server" Visible="false">
        <div class="lc-modal-overlay">
            <div class="lc-modal-card">
                <div class="lc-modal-icon">
                    <i class="bi bi-exclamation-triangle-fill"></i>
                </div>
                <div class="lc-modal-title"><asp:Literal ID="litModalTitle" runat="server" /></div>
                <div class="lc-modal-msg"><asp:Literal ID="litModalMsg" runat="server" /></div>
                <div class="lc-modal-actions">
                    <asp:Button ID="btnCancelUnlink" runat="server" CssClass="lc-modal-btn cancel"
                        OnClick="BtnCancelUnlink_Click" CausesValidation="false" />
                    <asp:Button ID="btnConfirmUnlink" runat="server" CssClass="lc-modal-btn danger"
                        OnClick="BtnConfirmUnlink_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </asp:Panel>

</div>
</asp:Content>
