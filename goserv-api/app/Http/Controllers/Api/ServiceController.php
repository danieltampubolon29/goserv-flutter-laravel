<?php

namespace App\Http\Controllers\Api;

use App\Models\User;
use App\Models\Service;
use App\Models\Point;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class ServiceController extends Controller
{
    public function userHistory(Request $request)
    {
        try {
            // Get authenticated user
            $user = Auth::user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 401);
            }

            // Get services for the authenticated user
            $services = Service::where('user_id', $user->id)
                ->orderBy('tanggal', 'desc')
                ->orderBy('created_at', 'desc')
                ->get();

            // Transform the data for response
            $transformedServices = $services->map(function ($service) {
                return [
                    'id' => $service->id,
                    'customer_name' => $service->customer_name,
                    'tanggal' => $service->tanggal,
                    'jenis_kendaraan' => $service->jenis_kendaraan,
                    'nomor_polisi' => $service->nomor_polisi,
                    'service_items' => is_string($service->service_items)
                        ? json_decode($service->service_items, true)
                        : $service->service_items,
                    'harga' => $service->harga,
                    'point' => $service->point,
                    'created_at' => $service->created_at->format('Y-m-d H:i:s'),
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $transformedServices,
                'total' => $services->count()
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error fetching history: ' . $e->getMessage()
            ], 500);
        }
    }

    // New method to get user points
    public function getUserPoints($userId)
    {
        try {
            $totalSetor = Point::where('user_id', $userId)
                ->where('transaksi', 'setor')
                ->sum('point');

            $totalTarik = Point::where('user_id', $userId)
                ->where('transaksi', 'tarik')
                ->sum('point');

            $totalPoints = $totalSetor - $totalTarik;

            return response()->json([
                'success' => true,
                'total_points' => $totalPoints
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error fetching user points: ' . $e->getMessage()
            ], 500);
        }
    }


    public function searchCustomers(Request $request)
    {
        $query = $request->input('query');
        $customers = User::where('role', 'customer')
            ->where('name', 'like', "%$query%")
            ->select('id', 'name')
            ->limit(10)
            ->get();

        return response()->json($customers);
    }

    public function index()
    {
        return response()->json(Service::all());
    }

    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'customer_name' => 'required|string',
            'tanggal' => 'required|date',
            'jenis_kendaraan' => 'required|string',
            'nomor_polisi' => 'required|string',
            'service_items' => 'required|array',
            'harga' => 'required|integer',
            'final_price' => 'integer',
            'points_used' => 'integer|min:0',
        ]);

        DB::beginTransaction();

        try {
            $pointsUsed = $request->input('points_used', 0);
            $finalPrice = $request->input('final_price', $request->harga);

            // Hitung total point user
            $totalSetor = Point::where('user_id', $request->user_id)
                ->where('transaksi', 'setor')
                ->sum('point');

            $totalTarik = Point::where('user_id', $request->user_id)
                ->where('transaksi', 'tarik')
                ->sum('point');

            $totalPoints = $totalSetor - $totalTarik;

            // Validasi point cukup
            if ($pointsUsed > $totalPoints) {
                return response()->json([
                    'success' => false,
                    'message' => 'Point tidak cukup untuk digunakan.',
                ], 400);
            }

            // Simpan data service
            $service = Service::create([
                'user_id' => $request->user_id,
                'customer_name' => $request->customer_name,
                'tanggal' => $request->tanggal,
                'jenis_kendaraan' => $request->jenis_kendaraan,
                'nomor_polisi' => $request->nomor_polisi,
                'service_items' => json_encode($request->service_items),
                'harga' => $finalPrice, // harga akhir setelah potong point
                'point' => $pointsUsed, // point yang digunakan untuk service ini
            ]);

            if ($pointsUsed > 0) {
                Point::create([
                    'user_id' => $request->user_id,
                    'mission_id' => null,
                    'point' => $pointsUsed,
                    'transaksi' => 'tarik', 
                    'tanggal' => now()->toDateString(),
                ]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Service berhasil ditambahkan.',
                'data' => $service,
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Gagal menyimpan service: ' . $e->getMessage(),
            ], 500);
        }
    }



    public function show($id)
    {
        return response()->json(Service::findOrFail($id));
    }

    public function update(Request $request, $id)
    {
        $service = Service::findOrFail($id);

        $request->validate([
            'user_id' => 'required|exists:users,id',
            'customer_name' => 'required|string',
            'tanggal' => 'required|date',
            'jenis_kendaraan' => 'required|string',
            'nomor_polisi' => 'required|string',
            'service_items' => 'required|array',
            'harga' => 'required|integer',
            'point' => 'integer',
        ]);

        $service->update([
            'user_id' => $request->user_id,
            'customer_name' => $request->customer_name,
            'tanggal' => $request->tanggal,
            'jenis_kendaraan' => $request->jenis_kendaraan,
            'nomor_polisi' => $request->nomor_polisi,
            'service_items' => json_encode($request->service_items),
            'harga' => $request->harga,
            'point' => $request->point ?? $service->point,
        ]);

        return response()->json([
            'message' => 'Service berhasil diperbarui',
            'data' => $service
        ]);
    }

    public function destroy($id)
    {
        $service = Service::findOrFail($id);
        $service->delete();

        return response()->json([
            'success' => true,
            'message' => 'Service berhasil dihapus'
        ]);
    }
}
