    <!-- start: Sidebar -->
    <div class="sidebar position-fixed top-0 bottom-0 bg-white border-end">
        <div class="d-flex align-items-center p-3">
            <a href="#" class="sidebar-logo text-uppercase fw-bold text-decoration-none text-blue fs-4">KMJP</a>
            <i class="sidebar-toggle ri-arrow-left-circle-line ms-auto fs-5 d-none d-md-block"></i>
        </div>
        <ul class="sidebar-menu p-3 m-0 mb-0">
            <li class="sidebar-menu-item active">
                <a
                    href="@if (Auth::check()) @if (Auth::user()->role === 'admin')
                            {{ route('admin.dashboard') }}
                        @elseif(Auth::user()->role === 'marketing')
                            {{ route('marketing.dashboard') }} @endif
                        @endif">
                    <i class="ri-dashboard-line sidebar-menu-item-icon"></i>Dashboard</a>
            </li>
            <li class="sidebar-menu-divider mt-3 mb-1 text-uppercase">MENU</li>
            <li class="sidebar-menu-item has-dropdown">
                <a href="#">
                    <i class="ri-pages-line sidebar-menu-item-icon"></i>
                    Data
                    <i class="ri-arrow-down-s-line sidebar-menu-item-accordion ms-auto"></i>
                </a>
                <ul class="sidebar-dropdown-menu">
                    <li class="sidebar-dropdown-menu-item">
                        <a href="{{ route('anggota.index') }}">
                            Anggota
                        </a>
                    </li>
                    <li class="sidebar-dropdown-menu-item">
                        <a href="{{ route('pencairan.index') }}">
                            Pencairan
                        </a>
                    </li>
                    <li class="sidebar-dropdown-menu-item">
                        <a href="{{ route('simpanan.index') }}">
                            Simpanan
                        </a>
                    </li>
                    <li class="sidebar-dropdown-menu-item">
                        <a href="{{ route('angsuran.index') }}">
                            Angsuran
                        </a>
                    </li>
                    <li class="sidebar-dropdown-menu-item">
                        <a href="{{ route('scan.angsuran') }}">
                            Scan Angsuran
                        </a>
                    </li>
                </ul>
            </li>
            <li class="sidebar-menu-item has-dropdown">
                <a href="#">
                    <i class="fas fa-shield-alt sidebar-menu-item-icon"></i>
                    Validasi Data
                    <i class="ri-arrow-down-s-line sidebar-menu-item-accordion ms-auto"></i>
                </a>
                <ul class="sidebar-dropdown-menu">
                    <li class="sidebar-dropdown-menu-item">
                        <a href="{{ route('validasi.pencairan') }}">
                            Pencairan
                        </a>
                    </li>
                    <li class="sidebar-dropdown-menu-item">
                        <a href="{{ route('validasi.simpanan') }}">
                            Simpanan
                        </a>
                    </li>
                    <li class="sidebar-dropdown-menu-item">
                        <a href="{{ route('validasi.angsuran') }}">
                            Angsuran
                        </a>
                    </li>
                </ul>
            </li>
            <li class="sidebar-menu-item has-dropdown">
                <a href="#">
                    <i class="ri-window-line sidebar-menu-item-icon"></i>
                    Laporan
                    <i class="ri-arrow-down-s-line sidebar-menu-item-accordion ms-auto"></i>
                </a>
                <ul class="sidebar-dropdown-menu">
                    <li class="sidebar-dropdown-menu-item">
                        <a href="{{ route('laporan.pencairan') }}">
                            Laporan Pencairan
                        </a>
                    </li>
                    <li class="sidebar-dropdown-menu-item">
                        <a href="{{ route('laporan.angsuran') }}">
                            Laporan Angsuran
                        </a>
                    </li>
                    <li class="sidebar-dropdown-menu-item">
                        <a href="{{ route('laporan.harian') }}">
                            Laporan Harian
                        </a>
                    </li>
                </ul>
            </li>
            <li class="sidebar-menu-item has-dropdown">
                <a href="#">
                    <i class="ri-time-line sidebar-menu-item-icon"></i>
                    Progres
                    <i class="ri-arrow-down-s-line sidebar-menu-item-accordion ms-auto"></i>
                </a>
                <ul class="sidebar-dropdown-menu">
                    @if (Auth::check())
                        @if (Auth::user()->role === 'admin')
                            <li class="sidebar-dropdown-menu-item">
                                <a href="{{ route('kasbon.index') }}">
                                    Kasbon Marketing
                                </a>
                            </li>
                            <li class="sidebar-dropdown-menu-item">
                                <a href="{{ route('progres.rekap-marketing') }}">
                                    Rekap Marketing
                                </a>
                            </li>
                            <li class="sidebar-dropdown-menu-item">
                                <a href="{{ route('admin.cek-data') }}">
                                    Cek Data Nasabah
                                </a>
                            </li>
                        @elseif(Auth::user()->role === 'marketing')
                            <li class="sidebar-dropdown-menu-item">
                                <a href="{{ route('progres.target-harian') }}">
                                    Jatuh Tempo
                                </a>
                            </li>
                            <li class="sidebar-dropdown-menu-item">
                                <a href="{{ route('progres.rekap-data') }}">
                                    Rekap Data
                                </a>
                            </li>
                            <li class="sidebar-dropdown-menu-item">
                                <a href="{{ route('marketing.cek-data') }}">
                                    Cek Data Nasabah
                                </a>
                            </li>
                        @endif
                    @endif
                </ul>
            </li>
            <li class="sidebar-menu-item has-dropdown">
                <a href="#">
                    <i class="ri-settings-3-line sidebar-menu-item-icon rotating-icon"></i>
                    Setting
                    <i class="ri-arrow-down-s-line sidebar-menu-item-accordion ms-auto"></i>
                </a>
                <ul class="sidebar-dropdown-menu">
                    <li class="sidebar-dropdown-menu-item">
                        <a href="#">
                            Profile
                        </a>
                    </li>
                    <li class="sidebar-dropdown-menu-item">
                        <a href="#">
                            Ganti Password
                        </a>
                    </li>
                </ul>
            </li>
            <li class="sidebar-menu-item has-dropdown">
                <a href="#">
                    <i class="ri-window-line sidebar-menu-item-icon"></i>
                    Kalender
                    <i class="ri-arrow-down-s-line sidebar-menu-item-accordion ms-auto"></i>
                </a>
                <ul class="sidebar-dropdown-menu">
                    <li class="sidebar-dropdown-menu-item">
                        @if (auth()->check() && auth()->user()->role === 'admin')
                            <a href="{{ route('hari-kerja.index') }}">
                                Setting Libur
                            </a>
                        @else
                            <a href="{{ route('hari-kerja.index') }}">
                                Hari Kerja
                            </a>
                        @endif
                    </li>
                </ul>
            </li>
            <li class="sidebar-menu-item">
                <a href="#" id="logout-link">
                    <i class="ri-logout-box-line sidebar-menu-item-icon"></i>
                    Log Out
                </a>
            </li>

            <div class="modal fade" data-bs-backdrop="false" id="logoutModal" tabindex="-1"
                aria-labelledby="logoutConfirmationModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content bg-dark text-white">
                        <div class="modal-header">
                            <h5 class="modal-title" id="logoutConfirmationModalLabel">Konfirmasi Log Out</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                                aria-label="Close"></button>
                        </div>
                        <div class="modal-body ">
                            Apakah Anda yakin ingin Log Out?
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                            <form action="{{ route('logout') }}" method="POST" style="display:inline;">
                                @csrf
                                <button type="submit" class="btn btn-danger">Log Out</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            <script>
                document.addEventListener('DOMContentLoaded', function() {
                    const logoutLink = document.getElementById('logout-link');
                    const logoutModal = new bootstrap.Modal(document.getElementById('logoutModal'));

                    logoutLink.addEventListener('click', function(e) {
                        e.preventDefault();
                        logoutModal.show();
                    });
                });
            </script>
        </ul>
    </div>
    <div class="sidebar-overlay"></div>
