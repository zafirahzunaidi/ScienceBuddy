<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="manageMaterials.aspx.cs"
    Inherits="ScienceBuddy.Teacher.manageMaterials" MasterPageFile="~/Site.Master"
    Title="Manage Materials" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root {
    --tc-primary: #6C63FF; --tc-secondary: #8B5CF6; --tc-hover: #5A52E0;
    --tc-light-bg: #F5F3FF; --tc-card-bg: #FFFFFF; --tc-border: #E5E7EB;
    --tc-text: #374151; --tc-muted: #6B7280;
    --tc-info: #3B82F6; --tc-warning: #F59E0B; --tc-success: #10B981; --tc-error: #EF4444;
}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Teaching</div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-book item-icon"></i><span class="item-label">Manage Materials</span>
        </a>
        <a href="#" class="sb-sidebar-item">
            <i class="bi bi-patch-question item-icon"></i><span class="item-label">Create Quiz</span>
        </a>
        <a href="#" class="sb-sidebar-item">
            <i class="bi bi-bar-chart item-icon"></i><span class="item-label">Student Progress</span>
        </a>
        <a href="#" class="sb-sidebar-item">
            <i class="bi bi-camera-video item-icon"></i><span class="item-label">Schedule Live Class</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Community</div>
        <a href="#" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i><span class="item-label">Forum</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="#" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span>
        </a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">Manage Materials</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- Status panels --%>
<asp:Panel ID="pnlPending" runat="server" Visible="false">
    <div style="display:flex;flex-direction:column;align-items:center;padding:3rem;text-align:center;">
        <div style="font-size:3rem;margin-bottom:1rem;">⏳</div>
        <h2 style="color:var(--tc-text);font-weight:800;">Verification Pending</h2>
        <p style="color:var(--tc-muted);max-width:450px;">Your certificate is under review. You will gain access once approved.</p>
    </div>
</asp:Panel>
<asp:Panel ID="pnlDenied" runat="server" Visible="false">
    <div style="display:flex;flex-direction:column;align-items:center;padding:3rem;text-align:center;">
        <div style="font-size:3rem;margin-bottom:1rem;">🚫</div>
        <h2 style="color:var(--tc-text);font-weight:800;">Access Denied</h2>
        <p style="color:var(--tc-muted);max-width:450px;">Your account cannot access this page. Please contact support.</p>
    </div>
</asp:Panel>

<%-- Main content --%>
<asp:Panel ID="pnlMain" runat="server" Visible="false">

<%-- Page header --%>
<div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:1rem;margin-bottom:1.5rem;">
    <div>
        <h1 style="font-size:1.5rem;font-weight:800;color:var(--tc-text);margin:0;">My Materials</h1>
        <p style="font-size:.85rem;color:var(--tc-muted);margin:.25rem 0 0;">Upload and manage learning materials for students.</p>
    </div>
    <asp:Button ID="btnShowUpload" runat="server" Text="+ Upload Material"
        CssClass="sb-btn sb-btn-primary" OnClick="btnShowUpload_Click" CausesValidation="false"
        style="background:var(--tc-primary);border:none;border-radius:10px;padding:.6rem 1.25rem;font-weight:700;font-size:.85rem;color:#fff;cursor:pointer;" />
</div>

<%-- Search & Filter --%>
<div style="display:flex;gap:.75rem;flex-wrap:wrap;margin-bottom:1.5rem;">
    <asp:TextBox ID="txtSearch" runat="server" placeholder="Search by title or description..."
        CssClass="form-control" style="flex:1;min-width:200px;border-radius:10px;border:1.5px solid var(--tc-border);padding:.55rem 1rem;font-size:.85rem;" />
    <asp:DropDownList ID="ddlFilterLevel" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterLevel_Changed"
        CssClass="form-control" style="min-width:140px;border-radius:10px;border:1.5px solid var(--tc-border);padding:.55rem .75rem;font-size:.85rem;" />
    <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click" CausesValidation="false"
        style="background:var(--tc-primary);border:none;border-radius:10px;padding:.55rem 1.25rem;font-weight:700;font-size:.85rem;color:#fff;cursor:pointer;" />
    <asp:Button ID="btnClear" runat="server" Text="Clear" OnClick="btnClear_Click" CausesValidation="false"
        style="background:#fff;border:1.5px solid var(--tc-border);border-radius:10px;padding:.55rem 1rem;font-weight:600;font-size:.85rem;color:var(--tc-text);cursor:pointer;" />
</div>

<%-- Status message --%>
<asp:Panel ID="pnlMessage" runat="server" Visible="false" style="margin-bottom:1rem;">
    <div style="padding:.75rem 1rem;border-radius:10px;font-size:.85rem;font-weight:600;">
        <asp:Literal ID="litMessage" runat="server" />
    </div>
</asp:Panel>

<%-- Materials list --%>
<asp:Panel ID="pnlMaterials" runat="server" Visible="false">
    <asp:Repeater ID="rptMaterials" runat="server" OnItemCommand="rptMaterials_ItemCommand">
        <ItemTemplate>
            <div style="background:var(--tc-card-bg);border:1.5px solid var(--tc-border);border-radius:14px;padding:1.25rem;margin-bottom:1rem;box-shadow:0 2px 8px rgba(0,0,0,.03);transition:box-shadow .2s;">
                <div style="display:flex;align-items:flex-start;gap:1rem;flex-wrap:wrap;">
                    <%-- Icon --%>
                    <div style="width:44px;height:44px;border-radius:10px;background:#EDE9FE;color:#6C63FF;display:flex;align-items:center;justify-content:center;font-size:1.2rem;flex-shrink:0;">
                        <i class='bi <%# GetFileIcon(Eval("materialType").ToString()) %>'></i>
                    </div>
                    <%-- Info --%>
                    <div style="flex:1;min-width:200px;">
                        <div style="font-weight:700;font-size:.9rem;color:var(--tc-text);margin-bottom:2px;"><%# HttpUtility.HtmlEncode(Eval("materialTitle")) %></div>
                        <div style="font-size:.8rem;color:var(--tc-muted);margin-bottom:6px;"><%# HttpUtility.HtmlEncode(TruncateText(Eval("materialContent")?.ToString(), 120)) %></div>
                        <div style="display:flex;gap:.75rem;flex-wrap:wrap;font-size:.75rem;color:var(--tc-muted);">
                            <span><i class="bi bi-folder2"></i> <%# HttpUtility.HtmlEncode(Eval("subtopicName")) %></span>
                            <span><i class="bi bi-file-earmark"></i> <%# HttpUtility.HtmlEncode(Eval("materialType")) %></span>
                            <span><i class="bi bi-calendar3"></i> <%# Eval("createdDate", "{0:d MMM yyyy}") %></span>
                            <span><i class="bi bi-translate"></i> <%# HttpUtility.HtmlEncode(Eval("language")) %></span>
                        </div>
                    </div>
                    <%-- Status badge --%>
                    <div style="flex-shrink:0;">
                        <span style='display:inline-block;padding:3px 10px;border-radius:50px;font-size:.7rem;font-weight:700;
                            <%# GetStatusStyle(Eval("status").ToString()) %>'><%# HttpUtility.HtmlEncode(Eval("status")) %></span>
                    </div>
                </div>
                <%-- Actions --%>
                <div style="display:flex;gap:.5rem;margin-top:.75rem;padding-top:.75rem;border-top:1px solid #F3F0FF;flex-wrap:wrap;">
                    <a href='<%# ResolveUrl("~/") + Eval("fileUrl") %>' target="_blank"
                        style="font-size:.78rem;font-weight:600;color:var(--tc-info);text-decoration:none;padding:4px 10px;border-radius:8px;border:1px solid #DBEAFE;background:#F0F7FF;">
                        <i class="bi bi-eye"></i> View</a>
                    <a href='<%# ResolveUrl("~/") + Eval("fileUrl") %>' download
                        style="font-size:.78rem;font-weight:600;color:var(--tc-success);text-decoration:none;padding:4px 10px;border-radius:8px;border:1px solid #D1FAE5;background:#ECFDF5;">
                        <i class="bi bi-download"></i> Download</a>
                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditMaterial" CommandArgument='<%# Eval("materialId") %>'
                        CausesValidation="false"
                        style="font-size:.78rem;font-weight:600;color:var(--tc-primary);text-decoration:none;padding:4px 10px;border-radius:8px;border:1px solid #EDE9FE;background:#F5F3FF;">
                        <i class="bi bi-pencil"></i> Edit</asp:LinkButton>
                    <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteMaterial" CommandArgument='<%# Eval("materialId") %>'
                        CausesValidation="false" OnClientClick="return confirm('Are you sure you want to delete this material?');"
                        style="font-size:.78rem;font-weight:600;color:var(--tc-error);text-decoration:none;padding:4px 10px;border-radius:8px;border:1px solid #FEE2E2;background:#FEF2F2;">
                        <i class="bi bi-trash"></i> Delete</asp:LinkButton>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</asp:Panel>

<%-- Empty state --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div style="display:flex;flex-direction:column;align-items:center;padding:3rem;text-align:center;color:var(--tc-muted);">
        <div style="font-size:3rem;opacity:.5;margin-bottom:.75rem;">📂</div>
        <div style="font-size:1rem;font-weight:700;color:var(--tc-text);margin-bottom:.25rem;">No materials uploaded yet.</div>
        <div style="font-size:.85rem;">Click "Upload Material" to add your first learning resource.</div>
    </div>
</asp:Panel>

<%-- Upload/Edit Form Panel --%>
<asp:Panel ID="pnlForm" runat="server" Visible="false">
    <div style="background:var(--tc-card-bg);border:1.5px solid var(--tc-border);border-radius:16px;padding:1.75rem;margin-bottom:1.5rem;box-shadow:0 4px 16px rgba(108,99,255,.06);">
        <h3 style="font-size:1.1rem;font-weight:800;color:var(--tc-text);margin:0 0 1.25rem;">
            <asp:Literal ID="litFormTitle" runat="server" Text="Upload New Material" /></h3>

        <asp:HiddenField ID="hidMaterialId" runat="server" Value="" />

        <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;margin-bottom:1rem;">
            <div>
                <label style="font-size:.8rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:4px;">Title *</label>
                <asp:TextBox ID="txtTitle" runat="server" MaxLength="150"
                    style="width:100%;border-radius:10px;border:1.5px solid var(--tc-border);padding:.55rem .75rem;font-size:.85rem;" />
                <asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle"
                    ErrorMessage="Title is required." Display="Dynamic" ForeColor="#EF4444"
                    style="font-size:.75rem;" ValidationGroup="MaterialForm" />
            </div>
            <div>
                <label style="font-size:.8rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:4px;">Language *</label>
                <asp:DropDownList ID="ddlLanguage" runat="server"
                    style="width:100%;border-radius:10px;border:1.5px solid var(--tc-border);padding:.55rem .75rem;font-size:.85rem;">
                    <asp:ListItem Value="EN" Text="English" />
                    <asp:ListItem Value="BM" Text="Bahasa Melayu" />
                    <asp:ListItem Value="BOTH" Text="Both" />
                </asp:DropDownList>
            </div>
        </div>

        <div style="margin-bottom:1rem;">
            <label style="font-size:.8rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:4px;">Description</label>
            <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="3"
                style="width:100%;border-radius:10px;border:1.5px solid var(--tc-border);padding:.55rem .75rem;font-size:.85rem;resize:vertical;" />
        </div>

        <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:1rem;margin-bottom:1rem;">
            <div>
                <label style="font-size:.8rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:4px;">Level</label>
                <asp:DropDownList ID="ddlLevel" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlLevel_Changed"
                    style="width:100%;border-radius:10px;border:1.5px solid var(--tc-border);padding:.55rem .75rem;font-size:.85rem;"
                    ValidationGroup="MaterialForm" />
            </div>
            <div>
                <label style="font-size:.8rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:4px;">Unit</label>
                <asp:DropDownList ID="ddlUnit" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlUnit_Changed"
                    style="width:100%;border-radius:10px;border:1.5px solid var(--tc-border);padding:.55rem .75rem;font-size:.85rem;"
                    ValidationGroup="MaterialForm" />
            </div>
            <div>
                <label style="font-size:.8rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:4px;">Subtopic *</label>
                <asp:DropDownList ID="ddlSubtopic" runat="server"
                    style="width:100%;border-radius:10px;border:1.5px solid var(--tc-border);padding:.55rem .75rem;font-size:.85rem;"
                    ValidationGroup="MaterialForm" />
            </div>
        </div>

        <div style="margin-bottom:1.25rem;">
            <label style="font-size:.8rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:4px;">
                File <asp:Literal ID="litFileRequired" runat="server" Text="*" /></label>
            <asp:FileUpload ID="fuFile" runat="server"
                style="width:100%;border-radius:10px;border:1.5px solid var(--tc-border);padding:.5rem .75rem;font-size:.85rem;background:#FAFAFA;" />
            <div style="font-size:.72rem;color:var(--tc-muted);margin-top:4px;">Accepted: PDF, DOC, DOCX, PPT, PPTX, JPG, JPEG, PNG (max 10 MB)</div>
            <asp:Panel ID="pnlCurrentFile" runat="server" Visible="false">
                <div style="font-size:.78rem;color:var(--tc-info);margin-top:4px;">
                    <i class="bi bi-paperclip"></i> Current file: <asp:Literal ID="litCurrentFile" runat="server" />
                </div>
            </asp:Panel>
        </div>

        <div style="display:flex;gap:.75rem;">
            <asp:Button ID="btnSave" runat="server" Text="Save Material" OnClick="btnSave_Click"
                ValidationGroup="MaterialForm"
                style="background:var(--tc-primary);border:none;border-radius:10px;padding:.6rem 1.5rem;font-weight:700;font-size:.85rem;color:#fff;cursor:pointer;" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click" CausesValidation="false"
                style="background:#fff;border:1.5px solid var(--tc-border);border-radius:10px;padding:.6rem 1.25rem;font-weight:600;font-size:.85rem;color:var(--tc-text);cursor:pointer;" />
        </div>
    </div>
</asp:Panel>

</asp:Panel><%-- /pnlMain --%>

</asp:Content>
