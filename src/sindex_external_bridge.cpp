#include <Rcpp.h>

#ifdef _WIN32
#include <windows.h>
#endif

using namespace Rcpp;

#ifdef _WIN32
typedef short (__cdecl *Fn_HtAgeToSI)(short, double, short, double, short, double*);
typedef short (__cdecl *Fn_AgeSIToHt)(short, double, short, double, double, double*);
typedef short (__cdecl *Fn_Y2BH)(short, double, double*);
typedef short (__cdecl *Fn_SCToSI)(short, char, char, double*);
typedef short (__cdecl *Fn_VersionNumber)();

static HMODULE g_sindex_dll = nullptr;
static std::string g_sindex_path;
static Fn_HtAgeToSI g_ht2si = nullptr;
static Fn_AgeSIToHt g_si2ht = nullptr;
static Fn_Y2BH g_y2bh = nullptr;
static Fn_SCToSI g_sc2si = nullptr;
static Fn_VersionNumber g_version_number = nullptr;

static void clear_external_state() {
  g_ht2si = nullptr;
  g_si2ht = nullptr;
  g_y2bh = nullptr;
  g_sc2si = nullptr;
  g_version_number = nullptr;
  g_sindex_path.clear();
  if (g_sindex_dll) {
    FreeLibrary(g_sindex_dll);
    g_sindex_dll = nullptr;
  }
}
#endif

// [[Rcpp::export]]
bool sindex_ext_set_dll(std::string dll_path) {
#ifdef _WIN32
  clear_external_state();

  HMODULE h = LoadLibraryA(dll_path.c_str());
  if (!h) {
    return false;
  }

  FARPROC p_ht2si = GetProcAddress(h, "Sindex_HtAgeToSI");
  FARPROC p_si2ht = GetProcAddress(h, "Sindex_AgeSIToHt");
  FARPROC p_y2bh = GetProcAddress(h, "Sindex_Y2BH");
  FARPROC p_sc2si = GetProcAddress(h, "Sindex_SCToSI");

  if (!p_ht2si || !p_si2ht || !p_y2bh || !p_sc2si) {
    FreeLibrary(h);
    return false;
  }

  g_sindex_dll = h;
  g_sindex_path = dll_path;
  g_ht2si = reinterpret_cast<Fn_HtAgeToSI>(p_ht2si);
  g_si2ht = reinterpret_cast<Fn_AgeSIToHt>(p_si2ht);
  g_y2bh = reinterpret_cast<Fn_Y2BH>(p_y2bh);
  g_sc2si = reinterpret_cast<Fn_SCToSI>(p_sc2si);

  FARPROC p_version = GetProcAddress(h, "Sindex_VersionNumber");
  g_version_number = reinterpret_cast<Fn_VersionNumber>(p_version);

  return true;
#else
  (void)dll_path;
  return false;
#endif
}

// [[Rcpp::export]]
void sindex_ext_clear_dll() {
#ifdef _WIN32
  clear_external_state();
#endif
}

// [[Rcpp::export]]
bool sindex_ext_is_loaded() {
#ifdef _WIN32
  return g_sindex_dll != nullptr;
#else
  return false;
#endif
}

// [[Rcpp::export]]
std::string sindex_ext_dll_path() {
#ifdef _WIN32
  return g_sindex_path;
#else
  return "";
#endif
}

// [[Rcpp::export]]
double sindex_ext_ht2si(int curve_index, double age, int age_type, double height, int est_type) {
#ifdef _WIN32
  if (!g_ht2si) {
    return NA_REAL;
  }

  double out_site = NA_REAL;
  short err = g_ht2si((short)curve_index, age, (short)age_type, height, (short)est_type, &out_site);
  if (err != 0) {
    return (double)err;
  }
  return out_site;
#else
  (void)curve_index; (void)age; (void)age_type; (void)height; (void)est_type;
  return NA_REAL;
#endif
}

// [[Rcpp::export]]
double sindex_ext_si2ht(int curve_index, double age, int age_type, double site_index, double y2bh) {
#ifdef _WIN32
  if (!g_si2ht) {
    return NA_REAL;
  }

  double out_height = NA_REAL;
  short err = g_si2ht((short)curve_index, age, (short)age_type, site_index, y2bh, &out_height);
  if (err != 0) {
    return (double)err;
  }
  return out_height;
#else
  (void)curve_index; (void)age; (void)age_type; (void)site_index; (void)y2bh;
  return NA_REAL;
#endif
}

// [[Rcpp::export]]
double sindex_ext_y2bh(int curve_index, double site_index) {
#ifdef _WIN32
  if (!g_y2bh) {
    return NA_REAL;
  }

  double out_y2bh = NA_REAL;
  short err = g_y2bh((short)curve_index, site_index, &out_y2bh);
  if (err != 0) {
    return (double)err;
  }
  return out_y2bh;
#else
  (void)curve_index; (void)site_index;
  return NA_REAL;
#endif
}

// [[Rcpp::export]]
double sindex_ext_sc2si(int species_index, std::string site_class, std::string fiz) {
#ifdef _WIN32
  if (!g_sc2si) {
    return NA_REAL;
  }

  char sc = site_class.empty() ? ' ' : site_class[0];
  char fz = fiz.empty() ? '\0' : fiz[0];

  double out_site = NA_REAL;
  short err = g_sc2si((short)species_index, sc, fz, &out_site);
  if (err != 0) {
    return (double)err;
  }
  return out_site;
#else
  (void)species_index; (void)site_class; (void)fiz;
  return NA_REAL;
#endif
}

// [[Rcpp::export]]
int sindex_ext_version_number() {
#ifdef _WIN32
  if (!g_version_number) {
    return -1;
  }
  return (int)g_version_number();
#else
  return -1;
#endif
}
