<?php

namespace App\Http\Controllers\Api;

use App\Models\Service;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;

class ServiceController extends Controller
{

    public function userHistory()
    {
        $userId = Auth::id();

        $services = Service::where('user_id', $userId)->get();

        return response()->json([
            'success' => true,
            'data' => $services
        ]);
    }

    public function index()
    {
        return response()->json(Service::all());
    }

    public function store(Request $request)
    {
        $request->validate([
            'customer_name' => 'required|string',
            'tanggal' => 'required|date',
            'jenis_kendaraan' => 'required|string',
            'nomor_polisi' => 'required|string',
            'service_items' => 'required|array',
            'harga' => 'required|integer',
            'point' => 'required|integer',
        ]);

        $service = Service::create([
            'customer_name' => $request->customer_name,
            'tanggal' => $request->tanggal,
            'jenis_kendaraan' => $request->jenis_kendaraan,
            'nomor_polisi' => $request->nomor_polisi,
            'service_items' => json_encode($request->service_items),
            'harga' => $request->harga,
            'point' => $request->point,
        ]);

        return response()->json([
            'message' => 'Service berhasil ditambahkan',
            'data' => $service
        ], 201);
    }

    public function show($id)
    {
        return response()->json(Service::findOrFail($id));
    }

    public function update(Request $request, $id)
    {
        $service = Service::findOrFail($id);

        $request->validate([
            'customer_name' => 'required|string',
            'tanggal' => 'required|date',
            'jenis_kendaraan' => 'required|string',
            'nomor_polisi' => 'required|string',
            'service_items' => 'required|array',
            'harga' => 'required|integer',
            'point' => 'required|integer',
        ]);

        $service->update([
            'customer_name' => $request->customer_name,
            'tanggal' => $request->tanggal,
            'jenis_kendaraan' => $request->jenis_kendaraan,
            'nomor_polisi' => $request->nomor_polisi,
            'service_items' => json_encode($request->service_items),
            'harga' => $request->harga,
            'point' => $request->point,
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
